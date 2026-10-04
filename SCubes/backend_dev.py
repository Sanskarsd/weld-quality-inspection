
from pathlib import Path
from datetime import datetime, timezone
import csv
import io
import sqlite3
import uuid

import torch
import torch.nn as nn
from fastapi import FastAPI, File, Form, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image
from torchvision import models, transforms

BASE_DIR = Path(__file__).resolve().parent
# `build_model` constructs a ResNet-50 (2048-feature classifier). Keep its
# checkpoint aligned with that architecture; the similarly named ResNet-18
# checkpoint is not compatible with this loader.
MODEL_PATH = BASE_DIR / "best_resnet_model.pth"
STORAGE_DIR = BASE_DIR / "storage"
IMAGE_DIR = STORAGE_DIR / "images"
DB_PATH = STORAGE_DIR / "weld_predictions.db"

IMAGE_DIR.mkdir(parents=True, exist_ok=True)

# Checkpoint metadata from the uploaded model.
CLASS_NAMES = ["Bad Weld", "Good Weld", "Defect"]
GOOD_WELD_CLASS = "Good Weld"
IMAGE_SIZE = 224
DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")


def build_model():
    model = models.resnet50(weights=None)

    # The uploaded checkpoint has a Sequential classifier where
    # fc.1 is the final Linear layer with 2048 -> 3 outputs.
    model.fc = nn.Sequential(
        nn.Dropout(p=0.0),
        nn.Linear(model.fc.in_features, len(CLASS_NAMES)),
    )

    checkpoint = torch.load(MODEL_PATH, map_location=DEVICE, weights_only=False)

    if isinstance(checkpoint, dict) and "model_state_dict" in checkpoint:
        state_dict = checkpoint["model_state_dict"]
    else:
        state_dict = checkpoint

    model.load_state_dict(state_dict)
    model.to(DEVICE)
    model.eval()
    return model


model = build_model()

transform = transforms.Compose([
    transforms.Resize((IMAGE_SIZE, IMAGE_SIZE)),
    transforms.ToTensor(),
    transforms.Normalize(
        mean=[0.485, 0.456, 0.406],
        std=[0.229, 0.224, 0.225],
    ),
])


def init_db():
    with sqlite3.connect(DB_PATH) as conn:
        conn.execute("""
            CREATE TABLE IF NOT EXISTS predictions (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                prediction_id TEXT NOT NULL UNIQUE,
                batch_no TEXT NOT NULL,
                image_filename TEXT NOT NULL,
                stored_image_path TEXT NOT NULL,
                uploaded_at TEXT NOT NULL,
                predicted_class TEXT NOT NULL,
                result INTEGER NOT NULL,
                confidence REAL NOT NULL
            )
        """)
        conn.commit()


init_db()

app = FastAPI(
    title="Weld Quality Inspection API",
    version="1.0.0",
    description="Prototype API for Good Weld / Bad Weld / Defect classification.",
)

# Allows a Flutter app to call the API during prototype development.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def root():
    return {
        "status": "online",
        "service": "Weld Quality Inspection API",
        "model": "ResNet-50",
        "classes": CLASS_NAMES,
    }


@app.get("/health")
def health():
    return {
        "status": "healthy",
        "device": str(DEVICE),
        "model_loaded": True,
    }


@app.post("/predict")
async def predict(
    file: UploadFile = File(...),
    batch_no: str = Form(...),
):
    if not file.filename:
        raise HTTPException(status_code=400, detail="Image file is required.")

    if not batch_no.strip():
        raise HTTPException(status_code=400, detail="batch_no is required.")

    allowed_types = {"image/jpeg", "image/png", "image/jpg", "image/webp"}
    if file.content_type and file.content_type not in allowed_types:
        raise HTTPException(
            status_code=400,
            detail="Only JPG, PNG, and WEBP images are supported.",
        )

    try:
        image_bytes = await file.read()
        image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid image file.")

    try:
        tensor = transform(image).unsqueeze(0).to(DEVICE)

        with torch.inference_mode():
            logits = model(tensor)
            probabilities = torch.softmax(logits, dim=1)
            confidence, class_index = torch.max(probabilities, dim=1)

        predicted_class = CLASS_NAMES[class_index.item()]
        confidence_value = float(confidence.item())

        # Business rule:
        # Good Weld -> true
        # Bad Weld / Defect -> false
        result = predicted_class == GOOD_WELD_CLASS

        prediction_id = str(uuid.uuid4())
        timestamp = datetime.now(timezone.utc).isoformat()

        safe_name = Path(file.filename).name
        extension = Path(safe_name).suffix.lower() or ".jpg"
        stored_filename = f"{prediction_id}{extension}"
        batch_folder = IMAGE_DIR / batch_no
        batch_folder.mkdir(parents=True, exist_ok=True)

        stored_path = batch_folder / stored_filename
        stored_path.write_bytes(image_bytes)

        relative_path = str(stored_path.relative_to(BASE_DIR)).replace("\\", "/")

        with sqlite3.connect(DB_PATH) as conn:
            conn.execute(
                """
                INSERT INTO predictions (
                    prediction_id,
                    batch_no,
                    image_filename,
                    stored_image_path,
                    uploaded_at,
                    predicted_class,
                    result,
                    confidence
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    prediction_id,
                    batch_no.strip(),
                    safe_name,
                    relative_path,
                    timestamp,
                    predicted_class,
                    int(result),
                    confidence_value,
                ),
            )
            conn.commit()

        return {
            "prediction_id": prediction_id,
            "batch_no": batch_no.strip(),
            "result": result,
            "message": (
                "Weld is properly done"
                if result
                else "Weld defect detected"
            ),
            "predicted_class": predicted_class,
            "confidence": round(confidence_value, 4),
            "image_filename": safe_name,
            "uploaded_at": timestamp,
        }

    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail=f"Prediction failed: {exc}",
        )


@app.get("/logs")
def get_logs(batch_no: str | None = None, limit: int = 100):
    limit = max(1, min(limit, 1000))

    with sqlite3.connect(DB_PATH) as conn:
        conn.row_factory = sqlite3.Row

        if batch_no:
            rows = conn.execute(
                """
                SELECT *
                FROM predictions
                WHERE batch_no = ?
                ORDER BY id DESC
                LIMIT ?
                """,
                (batch_no, limit),
            ).fetchall()
        else:
            rows = conn.execute(
                """
                SELECT *
                FROM predictions
                ORDER BY id DESC
                LIMIT ?
                """,
                (limit,),
            ).fetchall()

    return {
        "count": len(rows),
        "logs": [dict(row) for row in rows],
    }


@app.get("/logs/csv")
def export_logs_csv():
    with sqlite3.connect(DB_PATH) as conn:
        rows = conn.execute(
            """
            SELECT
                prediction_id,
                batch_no,
                image_filename,
                stored_image_path,
                uploaded_at,
                predicted_class,
                result,
                confidence
            FROM predictions
            ORDER BY id DESC
            """
        ).fetchall()

    output = io.StringIO()
    writer = csv.writer(output)

    writer.writerow([
        "prediction_id",
        "batch_no",
        "image_filename",
        "stored_image_path",
        "uploaded_at",
        "predicted_class",
        "result",
        "confidence",
    ])
    writer.writerows(rows)

    from fastapi.responses import Response

    return Response(
        content=output.getvalue(),
        media_type="text/csv",
        headers={
            "Content-Disposition": 'attachment; filename="weld_prediction_logs.csv"'
        },
    )
