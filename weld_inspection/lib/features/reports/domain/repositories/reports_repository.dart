import '../models/report_data.dart';

abstract interface class ReportsRepository {
  Future<ReportData> getReportData();

  Stream<ReportData> watchReportData();
}
