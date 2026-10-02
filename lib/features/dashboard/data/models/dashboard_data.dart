enum InspectionStatus { passed, failed, underReview }

enum DashboardDataSource { demo, live }

class InspectionSummary {
  const InspectionSummary({
    required this.total,
    required this.passed,
    required this.failed,
    required this.underReview,
  });

  final int total;
  final int passed;
  final int failed;
  final int underReview;
}

class RecentInspection {
  const RecentInspection({
    required this.id,
    required this.componentName,
    required this.dateLabel,
    required this.status,
    required this.resultSummary,
  });

  final String id;
  final String componentName;
  final String dateLabel;
  final InspectionStatus status;
  final String resultSummary;
}

class DashboardData {
  const DashboardData({
    required this.dataSource,
    required this.summary,
    required this.recentInspections,
  });

  final DashboardDataSource dataSource;
  final InspectionSummary summary;
  final List<RecentInspection> recentInspections;

  /// Source-owned copy. A live repository returns null, removing demo-only
  /// wording throughout the presentation without widget-specific conditions.
  String? get dataSourceNotice => switch (dataSource) {
    DashboardDataSource.demo => 'Demo data — backend not connected',
    DashboardDataSource.live => null,
  };

  String? get statusSummaryNote => switch (dataSource) {
    DashboardDataSource.demo => 'Static demonstration status distribution',
    DashboardDataSource.live => null,
  };
}
