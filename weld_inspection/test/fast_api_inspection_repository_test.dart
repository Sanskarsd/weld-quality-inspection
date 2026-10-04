import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:weld_inspection_app/features/inspection/data/repositories/fast_api_inspection_repository.dart';
import 'package:weld_inspection_app/features/inspection/domain/models/inspection_request.dart';
import 'package:weld_inspection_app/features/inspection/domain/models/inspection_result.dart';

void main() {
  final request = InspectionRequest(
    image: InspectionImage(fileName: 'weld.jpg', bytes: Uint8List(0)),
    type: InspectionType.weldVisual,
    componentName: 'Pressure vessel shell',
    jobBatchId: 'BATCH-42',
    notes: 'Review sample',
  );

  test('maps the current FastAPI prediction contract to a live result', () {
    final result = FastApiPredictionMapper.toInspectionResult(
      <String, dynamic>{
        'prediction_id': 'f1c9a825-7304-4c05-9efb-9f787b3bb121',
        'batch_no': 'BATCH-42',
        'result': false,
        'message': 'Weld defect detected',
        'predicted_class': 'Defect',
        'confidence': 0.9132,
        'image_filename': 'weld.jpg',
        'uploaded_at': '2026-10-04T12:00:00+00:00',
      },
      request: request,
      processingTime: const Duration(milliseconds: 420),
    );

    expect(result.inspectionId, 'f1c9a825-7304-4c05-9efb-9f787b3bb121');
    expect(result.status, InspectionStatus.failed);
    expect(result.defectDetected, isTrue);
    expect(result.defectType, 'Defect');
    expect(result.confidence, 0.9132);
    expect(result.componentName, request.componentName);
    expect(result.inspectionNotes, request.notes);
    expect(result.dataSource, InspectionDataSource.live);
  });
}
