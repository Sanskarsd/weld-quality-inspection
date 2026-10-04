import '../../../inspection/domain/models/inspection_result.dart';
import '../../../inspection_history/data/repositories/demo_inspection_history_store.dart';
import '../../domain/models/report_data.dart';
import '../../domain/repositories/reports_repository.dart';
import '../../domain/services/report_analytics_calculator.dart';

class DemoReportsRepository implements ReportsRepository {
  DemoReportsRepository(this._historyStore);

  final DemoInspectionHistoryStore _historyStore;

  @override
  Future<ReportData> getReportData() async =>
      _buildReportData(_historyStore.records);

  @override
  Stream<ReportData> watchReportData() =>
      _historyStore.changes.map(_buildReportData);

  ReportData _buildReportData(List<InspectionResult> records) =>
      ReportAnalyticsCalculator.fromInspections(records);
}
