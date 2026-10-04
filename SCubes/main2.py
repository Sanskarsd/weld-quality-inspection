import os
import copy
import argparse
from pathlib import Path
import yaml
import numpy as np
import matplotlib.pyplot as plt

from PIL import Image

import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader
from torchvision import models, transforms

from sklearn.metrics import (
    accuracy_score,
    precision_recall_fscore_support,
    confusion_matrix,
    classification_report
)


# ============================================================
# 1. DATASET
# ============================================================

class WeldingDataset(Dataset):
    """
    Dataset for image classification.

    Reads a YOLO detection split and turns each image into one
    classification sample. If an image has multiple classes, the highest
    class ID is used so defect annotations take precedence over good welds.
    """

    VALID_EXTENSIONS = (
        ".jpg",
        ".jpeg",
        ".png",
        ".bmp",
        ".tif",
        ".tiff",
        ".webp"
    )

    def __init__(self, root_dir, transform=None, class_names=None):
        self.root_dir = root_dir
        self.transform = transform

        self.classes = list(class_names or [])
        if not self.classes:
            raise ValueError("class_names must be loaded from data.yaml")

        self.samples = []

        label_dir = os.path.join(os.path.dirname(root_dir), "labels")
        if not os.path.isdir(label_dir):
            raise FileNotFoundError(f"Label directory not found: {label_dir}")

        for file in sorted(os.listdir(root_dir)):
            if not file.lower().endswith(self.VALID_EXTENSIONS):
                continue

            image_path = os.path.join(root_dir, file)
            label_path = os.path.join(
                label_dir,
                f"{os.path.splitext(file)[0]}.txt"
            )

            if not os.path.isfile(label_path):
                raise FileNotFoundError(
                    f"Label file not found for {image_path}: {label_path}"
                )

            class_ids = []
            with open(label_path, encoding="utf-8") as label_file:
                for line in label_file:
                    fields = line.split()
                    if fields:
                        class_id = int(fields[0])
                        if not 0 <= class_id < len(self.classes):
                            raise ValueError(
                                f"Invalid class ID {class_id} in {label_path}"
                            )
                        class_ids.append(class_id)

            if class_ids:
                self.samples.append((image_path, max(class_ids)))

        if len(self.samples) == 0:
            raise RuntimeError(
                f"No images found in {root_dir}.\n"
                f"Expected YOLO images and labels directories beside each other."
            )

    def __len__(self):
        return len(self.samples)

    def __getitem__(self, index):

        image_path, label = self.samples[index]

        image = Image.open(image_path).convert("RGB")

        if self.transform:
            image = self.transform(image)

        return image, label


# ============================================================
# 2. RESNET MODEL
# ============================================================

def create_resnet_model(
    num_classes,
    model_name="EfficientNet-B0",
    pretrained=True,
    unfreeze_last_two=True
):
    """
    Create a pretrained ResNet model.

    By default:
        - Entire ResNet backbone is frozen.
        - layer3 and layer4 are unfrozen.
        - Final FC classification layer is trainable.

    For ResNet:
        layer1 -> low-level features
        layer2 -> intermediate features
        layer3 -> high-level features
        layer4 -> high-level features

    Therefore, 'top two layers' is interpreted as
    the final two ResNet stages: layer3 and layer4.
    """

    if model_name.lower() == "resnet18":

        weights = (
            models.ResNet18_Weights.DEFAULT
            if pretrained
            else None
        )

        model = models.resnet18(weights=weights)

    elif model_name.lower() == "resnet34":

        weights = (
            models.ResNet34_Weights.DEFAULT
            if pretrained
            else None
        )

        model = models.resnet34(weights=weights)

    elif model_name.lower() == "resnet50":

        weights = (
            models.ResNet50_Weights.DEFAULT
            if pretrained
            else None
        )

        model = models.resnet50(weights=weights)

    elif model_name.lower() == "resnet101":

        weights = (
            models.ResNet101_Weights.DEFAULT
            if pretrained
            else None
        )

        model = models.resnet101(weights=weights)

    else:
        raise ValueError(
            "Supported models: resnet18, resnet34, "
            "resnet50, resnet101"
        )

    # --------------------------------------------------------
    # Freeze everything
    # --------------------------------------------------------

    for parameter in model.parameters():
        parameter.requires_grad = False

    # --------------------------------------------------------
    # Fine-tune top two ResNet stages
    # --------------------------------------------------------

    if unfreeze_last_two:

        for parameter in model.layer3.parameters():
            parameter.requires_grad = True

        for parameter in model.layer4.parameters():
            parameter.requires_grad = True

    # --------------------------------------------------------
    # Replace classification head
    # --------------------------------------------------------

    input_features = model.fc.in_features

    model.fc = nn.Sequential(
        nn.Dropout(p=0.3),
        nn.Linear(input_features, num_classes)
    )

    # FC is automatically trainable, but explicitly ensure it
    for parameter in model.fc.parameters():
        parameter.requires_grad = True

    return model


# ============================================================
# 3. DATA TRANSFORMS
# ============================================================

def get_transforms(image_size=224):

    train_transform = transforms.Compose([

        transforms.Resize(
            (image_size, image_size)
        ),

        transforms.RandomHorizontalFlip(
            p=0.5
        ),

        transforms.RandomRotation(
            degrees=10
        ),

        transforms.ColorJitter(
            brightness=0.2,
            contrast=0.2,
            saturation=0.2
        ),

        transforms.ToTensor(),

        transforms.Normalize(
            mean=[
                0.485,
                0.456,
                0.406
            ],
            std=[
                0.229,
                0.224,
                0.225
            ]
        )
    ])

    validation_transform = transforms.Compose([

        transforms.Resize(
            (image_size, image_size)
        ),

        transforms.ToTensor(),

        transforms.Normalize(
            mean=[
                0.485,
                0.456,
                0.406
            ],
            std=[
                0.229,
                0.224,
                0.225
            ]
        )
    ])

    return train_transform, validation_transform


# ============================================================
# 4. DATA LOADERS
# ============================================================

def resolve_dataset_root(data_dir):
    """Accept either the dataset directory or its duplicated outer folder."""
    data_dir = Path(data_dir)
    if (data_dir / "data.yaml").is_file():
        return str(data_dir)

    nested_dir = data_dir / data_dir.name
    if (nested_dir / "data.yaml").is_file():
        return str(nested_dir)

    raise FileNotFoundError(
        f"Could not find data.yaml in {data_dir} or {nested_dir}"
    )

def create_dataloaders(
    data_dir,
    batch_size=32,
    image_size=224,
    num_workers=2
):

    data_dir = resolve_dataset_root(data_dir)

    train_dir = os.path.join(data_dir, "train", "images")
    valid_dir = os.path.join(data_dir, "valid", "images")
    test_dir = os.path.join(data_dir, "test", "images")

    if not os.path.exists(train_dir):
        raise FileNotFoundError(
            f"Train directory not found: {train_dir}"
        )

    if not os.path.exists(valid_dir):
        raise FileNotFoundError(
            f"Validation directory not found: {valid_dir}"
        )

    if not os.path.exists(test_dir):
        raise FileNotFoundError(
            f"Test directory not found: {test_dir}"
        )

    train_transform, validation_transform = get_transforms(
        image_size=image_size
    )

    with open(os.path.join(data_dir, "data.yaml"), encoding="utf-8") as config_file:
        config = yaml.safe_load(config_file)

    classes = config.get("names", [])
    if not classes:
        raise RuntimeError(f"No class names found in {data_dir}/data.yaml")

    # --------------------------------------------------------
    # Create datasets
    # --------------------------------------------------------

    train_dataset = WeldingDataset(
        train_dir,
        transform=train_transform,
        class_names=classes
    )

    valid_dataset = WeldingDataset(
        valid_dir,
        transform=validation_transform,
        class_names=classes
    )

    test_dataset = WeldingDataset(
        test_dir,
        transform=validation_transform,
        class_names=classes
    )

    # --------------------------------------------------------
    # Create loaders
    # --------------------------------------------------------

    train_loader = DataLoader(
        train_dataset,
        batch_size=batch_size,
        shuffle=True,
        num_workers=num_workers,
        pin_memory=True
    )

    valid_loader = DataLoader(
        valid_dataset,
        batch_size=batch_size,
        shuffle=False,
        num_workers=num_workers,
        pin_memory=True
    )

    test_loader = DataLoader(
        test_dataset,
        batch_size=batch_size,
        shuffle=False,
        num_workers=num_workers,
        pin_memory=True
    )

    print("\nDataset Information")
    print("-" * 50)

    print(f"Classes       : {classes}")
    print(f"Number classes: {len(classes)}")

    print(
        f"Training images   : {len(train_dataset)}"
    )

    print(
        f"Validation images : {len(valid_dataset)}"
    )

    print(
        f"Testing images    : {len(test_dataset)}"
    )

    print("-" * 50)

    return (
        train_loader,
        valid_loader,
        test_loader,
        classes
    )


# ============================================================
# 5. TRAIN ONE EPOCH
# ============================================================

def train_one_epoch(
    model,
    dataloader,
    criterion,
    optimizer,
    device
):

    model.train()

    running_loss = 0.0
    correct = 0
    total = 0

    for images, labels in dataloader:

        images = images.to(
            device,
            non_blocking=True
        )

        labels = labels.to(
            device,
            non_blocking=True
        )

        # Clear gradients
        optimizer.zero_grad()

        # Forward pass
        outputs = model(images)

        # Calculate loss
        loss = criterion(
            outputs,
            labels
        )

        # Backpropagation
        loss.backward()

        # Update weights
        optimizer.step()

        running_loss += (
            loss.item() * images.size(0)
        )

        _, predicted = torch.max(
            outputs,
            1
        )

        total += labels.size(0)

        correct += (
            predicted == labels
        ).sum().item()

    epoch_loss = (
        running_loss / total
    )

    epoch_accuracy = (
        correct / total
    )

    return epoch_loss, epoch_accuracy


# ============================================================
# 6. VALIDATION
# ============================================================

def evaluate(
    model,
    dataloader,
    criterion,
    device
):

    model.eval()

    running_loss = 0.0
    correct = 0
    total = 0

    all_predictions = []
    all_labels = []

    with torch.no_grad():

        for images, labels in dataloader:

            images = images.to(
                device,
                non_blocking=True
            )

            labels = labels.to(
                device,
                non_blocking=True
            )

            outputs = model(images)

            loss = criterion(
                outputs,
                labels
            )

            running_loss += (
                loss.item() * images.size(0)
            )

            _, predicted = torch.max(
                outputs,
                1
            )

            total += labels.size(0)

            correct += (
                predicted == labels
            ).sum().item()

            all_predictions.extend(
                predicted.cpu().numpy()
            )

            all_labels.extend(
                labels.cpu().numpy()
            )

    epoch_loss = (
        running_loss / total
    )

    epoch_accuracy = (
        correct / total
    )

    return (
        epoch_loss,
        epoch_accuracy,
        np.array(all_labels),
        np.array(all_predictions)
    )


# ============================================================
# 7. TRAIN MODEL
# ============================================================

def train_model(
    data_dir,
    model_name="resnet50",
    epochs=20,
    batch_size=32,
    learning_rate=1e-4,
    image_size=224,
    num_workers=2,
    patience=5,
    save_path="best_resnet_model.pth"
):

    # --------------------------------------------------------
    # Device
    # --------------------------------------------------------

    device = torch.device(
        "cuda"
        if torch.cuda.is_available()
        else "cpu"
    )

    print("\nDevice:", device)

    if torch.cuda.is_available():

        print(
            "GPU:",
            torch.cuda.get_device_name(0)
        )

    # --------------------------------------------------------
    # Data
    # --------------------------------------------------------

    (
        train_loader,
        valid_loader,
        test_loader,
        classes
    ) = create_dataloaders(
        data_dir=data_dir,
        batch_size=batch_size,
        image_size=image_size,
        num_workers=num_workers
    )

    num_classes = len(classes)

    # --------------------------------------------------------
    # Model
    # --------------------------------------------------------

    model = create_resnet_model(
        num_classes=num_classes,
        model_name=model_name,
        pretrained=True,
        unfreeze_last_two=True
    )

    model = model.to(device)

    # --------------------------------------------------------
    # Loss
    # --------------------------------------------------------

    criterion = nn.CrossEntropyLoss()

    # --------------------------------------------------------
    # Only train parameters where requires_grad=True
    # --------------------------------------------------------

    trainable_parameters = [
        parameter
        for parameter in model.parameters()
        if parameter.requires_grad
    ]

    print(
        "\nTrainable parameters:",
        sum(
            p.numel()
            for p in trainable_parameters
        )
    )

    # --------------------------------------------------------
    # Optimizer
    # --------------------------------------------------------

    optimizer = optim.AdamW(
        trainable_parameters,
        lr=learning_rate,
        weight_decay=1e-4
    )

    # --------------------------------------------------------
    # Learning rate scheduler
    # --------------------------------------------------------

    scheduler = optim.lr_scheduler.ReduceLROnPlateau(
        optimizer,
        mode="min",
        factor=0.5,
        patience=2
    )

    # --------------------------------------------------------
    # History
    # --------------------------------------------------------

    history = {
        "train_loss": [],
        "train_accuracy": [],
        "val_loss": [],
        "val_accuracy": []
    }

    best_val_accuracy = 0.0

    best_model_weights = copy.deepcopy(
        model.state_dict()
    )

    epochs_without_improvement = 0

    # ========================================================
    # TRAINING LOOP
    # ========================================================

    print("\nStarting training...")
    print("=" * 60)

    for epoch in range(epochs):

        print(
            f"\nEpoch [{epoch + 1}/{epochs}]"
        )

        # ----------------------------------------------------
        # Training
        # ----------------------------------------------------

        train_loss, train_accuracy = train_one_epoch(
            model=model,
            dataloader=train_loader,
            criterion=criterion,
            optimizer=optimizer,
            device=device
        )

        # ----------------------------------------------------
        # Validation
        # ----------------------------------------------------

        (
            val_loss,
            val_accuracy,
            _,
            _
        ) = evaluate(
            model=model,
            dataloader=valid_loader,
            criterion=criterion,
            device=device
        )

        # Scheduler
        scheduler.step(val_loss)

        # Save history
        history["train_loss"].append(
            train_loss
        )

        history["train_accuracy"].append(
            train_accuracy
        )

        history["val_loss"].append(
            val_loss
        )

        history["val_accuracy"].append(
            val_accuracy
        )

        print(
            f"Train Loss: {train_loss:.4f} | "
            f"Train Acc: {train_accuracy:.4f}"
        )

        print(
            f"Val Loss:   {val_loss:.4f} | "
            f"Val Acc:    {val_accuracy:.4f}"
        )

        # ----------------------------------------------------
        # Save best model
        # ----------------------------------------------------

        if val_accuracy > best_val_accuracy:

            best_val_accuracy = val_accuracy

            best_model_weights = copy.deepcopy(
                model.state_dict()
            )

            torch.save(
                {
                    "model_state_dict":
                        model.state_dict(),

                    "classes":
                        classes,

                    "model_name":
                        model_name,

                    "num_classes":
                        num_classes,

                    "image_size":
                        image_size,

                    "val_accuracy":
                        val_accuracy
                },
                save_path
            )

            print(
                f"✓ Best model saved: {save_path}"
            )

            epochs_without_improvement = 0

        else:

            epochs_without_improvement += 1

        # ----------------------------------------------------
        # Early stopping
        # ----------------------------------------------------

        if epochs_without_improvement >= patience:

            print(
                "\nEarly stopping triggered."
            )

            break

    # ========================================================
    # LOAD BEST MODEL
    # ========================================================

    model.load_state_dict(
        best_model_weights
    )

    # ========================================================
    # TEST
    # ========================================================

    print("\n")
    print("=" * 60)
    print("FINAL TEST EVALUATION")
    print("=" * 60)

    (
        test_loss,
        test_accuracy,
        y_true,
        y_pred
    ) = evaluate(
        model=model,
        dataloader=test_loader,
        criterion=criterion,
        device=device
    )

    print(
        f"\nTest Loss     : {test_loss:.4f}"
    )

    print(
        f"Test Accuracy : {test_accuracy:.4f}"
    )

    # --------------------------------------------------------
    # Precision / Recall / F1
    # --------------------------------------------------------

    precision, recall, f1, _ = (
        precision_recall_fscore_support(
            y_true,
            y_pred,
            average="weighted",
            zero_division=0
        )
    )

    print(
        f"Precision     : {precision:.4f}"
    )

    print(
        f"Recall        : {recall:.4f}"
    )

    print(
        f"F1 Score      : {f1:.4f}"
    )

    # --------------------------------------------------------
    # Classification report
    # --------------------------------------------------------

    print("\nClassification Report")
    print("-" * 60)

    print(
        classification_report(
            y_true,
            y_pred,
            target_names=classes,
            zero_division=0
        )
    )

    # --------------------------------------------------------
    # Confusion Matrix
    # --------------------------------------------------------

    cm = confusion_matrix(
        y_true,
        y_pred
    )

    plot_confusion_matrix(
        cm,
        classes
    )

    # --------------------------------------------------------
    # Training curves
    # --------------------------------------------------------

    plot_training_history(
        history
    )

    return model, history


# ============================================================
# 8. CONFUSION MATRIX
# ============================================================

def plot_confusion_matrix(
    cm,
    classes
):

    plt.figure(
        figsize=(8, 6)
    )

    plt.imshow(
        cm,
        interpolation="nearest"
    )

    plt.title(
        "Confusion Matrix"
    )

    plt.colorbar()

    tick_marks = np.arange(
        len(classes)
    )

    plt.xticks(
        tick_marks,
        classes,
        rotation=45,
        ha="right"
    )

    plt.yticks(
        tick_marks,
        classes
    )

    plt.xlabel(
        "Predicted Label"
    )

    plt.ylabel(
        "True Label"
    )

    # Add values
    for i in range(cm.shape[0]):

        for j in range(cm.shape[1]):

            plt.text(
                j,
                i,
                str(cm[i, j]),
                horizontalalignment="center",
                verticalalignment="center"
            )

    plt.tight_layout()

    plt.show()


# ============================================================
# 9. TRAINING CURVES
# ============================================================

def plot_training_history(history):

    # --------------------------------------------------------
    # Accuracy
    # --------------------------------------------------------

    plt.figure(
        figsize=(8, 5)
    )

    plt.plot(
        history["train_accuracy"],
        label="Training Accuracy"
    )

    plt.plot(
        history["val_accuracy"],
        label="Validation Accuracy"
    )

    plt.xlabel(
        "Epoch"
    )

    plt.ylabel(
        "Accuracy"
    )

    plt.title(
        "Training and Validation Accuracy"
    )

    plt.legend()

    plt.grid()

    plt.show()

    # --------------------------------------------------------
    # Loss
    # --------------------------------------------------------

    plt.figure(
        figsize=(8, 5)
    )

    plt.plot(
        history["train_loss"],
        label="Training Loss"
    )

    plt.plot(
        history["val_loss"],
        label="Validation Loss"
    )

    plt.xlabel(
        "Epoch"
    )

    plt.ylabel(
        "Loss"
    )

    plt.title(
        "Training and Validation Loss"
    )

    plt.legend()

    plt.grid()

    plt.show()


# ============================================================
# 10. SINGLE IMAGE PREDICTION
# ============================================================

def predict_image(
    image_path,
    model,
    classes,
    device=None,
    image_size=224
):

    if device is None:

        device = torch.device(
            "cuda"
            if torch.cuda.is_available()
            else "cpu"
        )

    transform = transforms.Compose([

        transforms.Resize(
            (image_size, image_size)
        ),

        transforms.ToTensor(),

        transforms.Normalize(
            mean=[
                0.485,
                0.456,
                0.406
            ],
            std=[
                0.229,
                0.224,
                0.225
            ]
        )
    ])

    image = Image.open(
        image_path
    ).convert("RGB")

    image_tensor = transform(
        image
    )

    image_tensor = image_tensor.unsqueeze(0)

    image_tensor = image_tensor.to(
        device
    )

    model.eval()

    with torch.no_grad():

        outputs = model(
            image_tensor
        )

        probabilities = torch.softmax(
            outputs,
            dim=1
        )

        confidence, predicted = torch.max(
            probabilities,
            1
        )

    predicted_class = classes[
        predicted.item()
    ]

    confidence = confidence.item()

    return (
        predicted_class,
        confidence
    )


def load_saved_model(checkpoint_path, device=None):
    """Load a saved checkpoint for later image prediction."""
    if device is None:
        device = torch.device(
            "cuda"
            if torch.cuda.is_available()
            else "cpu"
        )

    checkpoint = torch.load(
        checkpoint_path,
        map_location=device,
        weights_only=True
    )

    model = create_resnet_model(
        num_classes=checkpoint["num_classes"],
        model_name=checkpoint["model_name"],
        pretrained=False,
        unfreeze_last_two=True
    )

    model.load_state_dict(checkpoint["model_state_dict"])
    model.to(device)
    model.eval()

    return model, checkpoint["classes"], checkpoint["image_size"]


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Train a ResNet on welding images")
    parser.add_argument(
        "--dataset",
        default="The Welding Defect Dataset - v2",
        help="Dataset directory containing data.yaml"
    )
    parser.add_argument("--model", default="resnet18")
    parser.add_argument("--epochs", type=int, default=20)
    parser.add_argument("--batch-size", type=int, default=32)
    parser.add_argument("--num-workers", type=int, default=0)
    parser.add_argument("--save-path", default="best_resnet18_model.pth")
    args = parser.parse_args()

    train_model(
        data_dir=args.dataset,
        model_name=args.model,
        epochs=args.epochs,
        batch_size=args.batch_size,
        num_workers=args.num_workers,
        save_path=args.save_path
    )
