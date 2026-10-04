import 'package:flutter_test/flutter_test.dart';
import 'package:weld_inspection_app/features/inspection/domain/models/inspection_result.dart';
import 'package:weld_inspection_app/features/inspection_history/data/repositories/demo_inspection_history_store.dart';
import 'package:weld_inspection_app/features/reports/data/services/pdf_report_generator.dart';
import 'package:weld_inspection_app/features/reports/domain/services/report_analytics_calculator.dart';
import 'package:weld_inspection_app/features/reports/domain/services/report_generator.dart';

void main() {
  final records = DemoInspectionHistoryStore.initialRecords;

  test('single inspection PDF contains non-empty output without an image', () async {
    final inspection = records.first;
    final report = await PdfReportGenerator().generateSingleInspection(inspection);
    expect(report.bytes, isNotEmpty);
    expect(report.filename, contains(inspection.inspectionId));
  });

  test('summary analytics and PDF use the supplied inspection records', () async {
    final analytics = ReportAnalyticsCalculator.fromInspections(records.take(2).toList());
    final report = await PdfReportGenerator().generateSummary(records.take(2).toList(), analytics);
    expect(analytics.summary.totalInspections, 2);
    expect(report.bytes, isNotEmpty);
  });

  test('period filter selects only its requested batch', () {
    final selected = ReportFilter(jobBatchId: 'JOB-A').apply([
      _record('A', 'JOB-A'),
      _record('B', 'JOB-B'),
    ]);
    expect(selected.map((record) => record.inspectionId), ['A']);
  });
}

InspectionResult _record(String id, String batch) => InspectionResult(
  inspectionId: id,
  status: InspectionStatus.passed,
  confidence: 0.9,
  defectDetected: false,
  processingTime: const Duration(milliseconds: 10),
  completedAt: DateTime(2026, 1, 1),
  imageName: '$id.jpg',
  dataSource: InspectionDataSource.demo,
  jobBatchId: batch,
);
