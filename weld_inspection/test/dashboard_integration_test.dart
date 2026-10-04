import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:weld_inspection_app/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:weld_inspection_app/features/inspection/data/repositories/demo_inspection_repository.dart';
import 'package:weld_inspection_app/features/inspection/domain/models/inspection_request.dart';
import 'package:weld_inspection_app/features/inspection_history/data/repositories/demo_inspection_history_store.dart';
import 'package:weld_inspection_app/features/reports/data/repositories/demo_reports_repository.dart';

void main() {
  test(
    'dashboard, history, and reports share newly completed inspection data',
    () async {
      final store = DemoInspectionHistoryStore();
      final dashboard = DemoDashboardRepository(store);
      final reports = DemoReportsRepository(store);
      final inspections = DemoInspectionRepository(
        store,
        processingDelay: Duration.zero,
      );

      final before = await dashboard.getDashboardData();
      final result = await inspections.runInspection(
        InspectionRequest(
          image: InspectionImage(
            fileName: 'dashboard-weld.jpg',
            bytes: Uint8List.fromList(<int>[1, 2, 3]),
          ),
          type: InspectionType.weldVisual,
          componentName: 'Pressure Vessel Shell A01',
          jobBatchId: 'JOB-2026-001',
          notes: 'Final weld inspection after fabrication.',
        ),
      );
      final after = await dashboard.getDashboardData();
      final report = await reports.getReportData();

      expect(after.summary.total, before.summary.total + 1);
      expect(after.recentInspections.first.id, result.inspectionId);
      expect(report.summary.totalInspections, after.summary.total);
      expect(
        store.byId(result.inspectionId)?.componentName,
        'Pressure Vessel Shell A01',
      );
    },
  );
}
