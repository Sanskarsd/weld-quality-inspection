import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:weld_inspection_app/features/inspection/data/repositories/demo_inspection_repository.dart';
import 'package:weld_inspection_app/features/inspection/domain/models/inspection_request.dart';
import 'package:weld_inspection_app/features/inspection/domain/models/inspection_result.dart';
import 'package:weld_inspection_app/features/inspection_history/data/repositories/demo_inspection_history_repository.dart';
import 'package:weld_inspection_app/features/inspection_history/data/repositories/demo_inspection_history_store.dart';
import 'package:weld_inspection_app/features/reports/data/repositories/demo_reports_repository.dart';

void main() {
  test('completed demo inspection is preserved in shared history without duplicates', () async {
    final store = DemoInspectionHistoryStore();
    final inspectionRepository = DemoInspectionRepository(
      store,
      processingDelay: Duration.zero,
    );
    final historyRepository = DemoInspectionHistoryRepository(
      store,
      delay: Duration.zero,
    );
    final reportsRepository = DemoReportsRepository(store);
    final initialRecords = await historyRepository.getHistory();
    final initialReport = await reportsRepository.getReportData();
    final result = await inspectionRepository.runInspection(
      InspectionRequest(
        image: InspectionImage(
          fileName: 'new-weld.jpg',
          bytes: Uint8List.fromList(<int>[1, 2, 3]),
        ),
        type: InspectionType.weldVisual,
        componentName: 'Pressure Vessel Shell',
        jobBatchId: 'JOB-2026-001',
        notes: 'Final weld inspection after fabrication.',
      ),
    );
    store.add(result);
    final records = await historyRepository.getHistory();
    final saved = await historyRepository.getById(result.inspectionId);
    final updatedReport = await reportsRepository.getReportData();
    expect(records, hasLength(initialRecords.length + 1));
    expect(saved?.inspectionId, result.inspectionId);
    expect(saved?.status, result.status);
    expect(saved?.confidence, result.confidence);
    expect(saved?.defectType, result.defectType);
    expect(saved?.severity, result.severity);
    expect(saved?.componentName, 'Pressure Vessel Shell');
    expect(saved?.jobBatchId, 'JOB-2026-001');
    expect(saved?.inspectionType, InspectionType.weldVisual);
    expect(saved?.inspectionNotes, 'Final weld inspection after fabrication.');
    expect(saved?.image?.fileName, 'new-weld.jpg');
    expect(saved?.image?.bytes, orderedEquals(<int>[1, 2, 3]));
    expect(
      updatedReport.summary.totalInspections,
      initialReport.summary.totalInspections + 1,
    );
    expect(
      updatedReport.summary.passedInspections,
      result.status == InspectionStatus.passed
          ? initialReport.summary.passedInspections + 1
          : initialReport.summary.passedInspections,
    );
    expect(
      updatedReport.summary.failedInspections,
      result.status == InspectionStatus.failed
          ? initialReport.summary.failedInspections + 1
          : initialReport.summary.failedInspections,
    );
    expect(
      updatedReport.summary.underReviewInspections,
      result.status == InspectionStatus.underReview
          ? initialReport.summary.underReviewInspections + 1
          : initialReport.summary.underReviewInspections,
    );
    expect(
      updatedReport.inspectionTrend.any((point) => point.total > 0),
      isTrue,
    );
    if (result.defectDetected) {
      expect(
        updatedReport.summary.totalDefects,
        initialReport.summary.totalDefects + 1,
      );
      expect(
        updatedReport.defectDistribution.any(
          (item) => item.defectType == result.defectType,
        ),
        isTrue,
      );
      expect(
        updatedReport.severityDistribution.any(
          (item) => item.severity == result.severity?.label,
        ),
        isTrue,
      );
    }
  });
}
