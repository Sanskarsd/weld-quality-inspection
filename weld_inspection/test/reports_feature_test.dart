import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weld_inspection_app/features/reports/application/controllers/reports_controller.dart';
import 'package:weld_inspection_app/features/reports/application/providers/reports_providers.dart';
import 'package:weld_inspection_app/features/reports/data/repositories/demo_reports_repository.dart';
import 'package:weld_inspection_app/features/reports/domain/models/report_data.dart';
import 'package:weld_inspection_app/features/reports/domain/repositories/reports_repository.dart';
import 'package:weld_inspection_app/features/reports/presentation/reports_screen.dart';
import 'package:weld_inspection_app/features/inspection_history/data/repositories/demo_inspection_history_store.dart';

void main() {
  test('demo repository returns complete report analytics', () async {
    final data = await DemoReportsRepository(DemoInspectionHistoryStore())
        .getReportData();
    expect(data.summary.totalInspections, greaterThan(0));
    expect(data.defectDistribution, isNotEmpty);
    expect(data.inspectionTrend, isNotEmpty);
  });

  test('controller loads report data and refreshes the repository', () async {
    final repository = _CountingReportsRepository();
    final container = ProviderContainer(
      overrides: [reportsRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    container.read(reportsControllerProvider);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(
      container.read(reportsControllerProvider).phase,
      ReportsPhase.loaded,
    );
    expect(
      container.read(reportsControllerProvider).data!.summary.totalInspections,
      1,
    );
    await container.read(reportsControllerProvider.notifier).refresh();
    expect(repository.calls, 2);
  });

  testWidgets('reports screen renders without overflow on a narrow viewport', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ReportsScreen())),
    );
    await tester.pumpAndSettle();
    expect(find.text('Reports & Analysis'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _CountingReportsRepository implements ReportsRepository {
  int calls = 0;
  @override
  Future<ReportData> getReportData() async {
    calls++;
    return ReportData(
      summary: const ReportSummary(
        totalInspections: 1,
        passedInspections: 1,
        failedInspections: 0,
        underReviewInspections: 0,
        passRate: 100,
        averageConfidence: 99,
        averageProcessingTime: Duration(seconds: 1),
        totalDefects: 0,
      ),
      defectDistribution: const [],
      severityDistribution: const [],
      inspectionTrend: const [],
    );
  }

  @override
  Stream<ReportData> watchReportData() => const Stream<ReportData>.empty();
}
