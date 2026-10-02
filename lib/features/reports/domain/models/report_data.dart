class ReportSummary {
  const ReportSummary({
    required this.totalInspections,
    required this.passedInspections,
    required this.failedInspections,
    required this.underReviewInspections,
    required this.passRate,
    required this.averageConfidence,
    required this.averageProcessingTime,
    required this.totalDefects,
  });
  final int totalInspections,
      passedInspections,
      failedInspections,
      underReviewInspections,
      totalDefects;
  final double passRate, averageConfidence;
  final Duration averageProcessingTime;
}

class DefectDistribution {
  const DefectDistribution({
    required this.defectType,
    required this.count,
    required this.percentage,
  });
  final String defectType;
  final int count;
  final double percentage;
}

class SeverityDistribution {
  const SeverityDistribution({
    required this.severity,
    required this.count,
    required this.percentage,
  });
  final String severity;
  final int count;
  final double percentage;
}

class InspectionTrendPoint {
  const InspectionTrendPoint({
    required this.label,
    required this.total,
    required this.passed,
    required this.failed,
    required this.underReview,
  });
  final String label;
  final int total, passed, failed, underReview;
}

class ReportData {
  const ReportData({
    required this.summary,
    required this.defectDistribution,
    required this.severityDistribution,
    required this.inspectionTrend,
  });
  final ReportSummary summary;
  final List<DefectDistribution> defectDistribution;
  final List<SeverityDistribution> severityDistribution;
  final List<InspectionTrendPoint> inspectionTrend;
}
