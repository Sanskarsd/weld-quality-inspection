import '../../../inspection/domain/models/inspection_result.dart' as domain;
import '../../../inspection_history/data/repositories/demo_inspection_history_store.dart';
import '../models/dashboard_data.dart';

abstract interface class DashboardRepository {
  Future<DashboardData> getDashboardData();

  Stream<DashboardData> watchDashboardData();
}

/// Temporary, clearly labelled demonstration data until the inspection API is
/// available. Replace this implementation with a REST-backed repository.
class DemoDashboardRepository implements DashboardRepository {
  DemoDashboardRepository(this._historyStore);

  final DemoInspectionHistoryStore _historyStore;

  @override
  Future<DashboardData> getDashboardData() async =>
      _buildData(_historyStore.records);

  @override
  Stream<DashboardData> watchDashboardData() =>
      _historyStore.changes.map(_buildData);

  DashboardData _buildData(List<domain.InspectionResult> records) {
    final passed = records
        .where((record) => record.status == domain.InspectionStatus.passed)
        .length;
    final failed = records
        .where((record) => record.status == domain.InspectionStatus.failed)
        .length;
    final underReview = records
        .where((record) => record.status == domain.InspectionStatus.underReview)
        .length;
    return DashboardData(
      dataSource: DashboardDataSource.demo,
      summary: InspectionSummary(
        total: records.length,
        passed: passed,
        failed: failed,
        underReview: underReview,
      ),
      recentInspections: records.take(5).map(_recentInspection).toList(),
    );
  }

  RecentInspection _recentInspection(
    domain.InspectionResult record,
  ) => RecentInspection(
    id: record.inspectionId,
    componentName: record.componentName ?? 'Component unavailable',
    dateLabel:
        '${record.completedAt.day.toString().padLeft(2, '0')}/${record.completedAt.month.toString().padLeft(2, '0')}/${record.completedAt.year}',
    status: switch (record.status) {
      domain.InspectionStatus.passed => InspectionStatus.passed,
      domain.InspectionStatus.failed => InspectionStatus.failed,
      domain.InspectionStatus.underReview => InspectionStatus.underReview,
    },
    resultSummary: record.defectDetected
        ? record.defectType ?? 'Defect requires review'
        : 'No defect detected',
  );
}
