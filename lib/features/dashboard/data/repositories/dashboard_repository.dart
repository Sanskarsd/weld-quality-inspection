import '../models/dashboard_data.dart';

abstract interface class DashboardRepository {
  DashboardData getDashboardData();
}

/// Temporary, clearly labelled demonstration data until the inspection API is
/// available. Replace this implementation with a REST-backed repository.
class DemoDashboardRepository implements DashboardRepository {
  const DemoDashboardRepository();

  @override
  DashboardData getDashboardData() {
    return const DashboardData(
      dataSource: DashboardDataSource.demo,
      summary: InspectionSummary(
        total: 128,
        passed: 104,
        failed: 12,
        underReview: 12,
      ),
      recentInspections: <RecentInspection>[
        RecentInspection(
          id: 'DEMO-WI-1001',
          componentName: 'Pressure Vessel Shell',
          dateLabel: 'Demo · 30 Sep 2026',
          status: InspectionStatus.passed,
          resultSummary: 'No review items recorded',
        ),
        RecentInspection(
          id: 'DEMO-WI-1002',
          componentName: 'Heat Exchanger Nozzle',
          dateLabel: 'Demo · 30 Sep 2026',
          status: InspectionStatus.underReview,
          resultSummary: 'Awaiting quality review',
        ),
        RecentInspection(
          id: 'DEMO-WI-1003',
          componentName: 'Pipe Spool Assembly',
          dateLabel: 'Demo · 29 Sep 2026',
          status: InspectionStatus.failed,
          resultSummary: 'Demo defect flag for review',
        ),
        RecentInspection(
          id: 'DEMO-WI-1004',
          componentName: 'Reactor Support Skirt',
          dateLabel: 'Demo · 29 Sep 2026',
          status: InspectionStatus.passed,
          resultSummary: 'No review items recorded',
        ),
      ],
    );
  }
}
