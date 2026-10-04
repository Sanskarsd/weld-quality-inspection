import '../../../inspection/domain/models/inspection_result.dart';
import '../models/report_data.dart';

/// Shared analytics calculation for Reports and generated documents.
class ReportAnalyticsCalculator {
  const ReportAnalyticsCalculator._();

  static ReportData fromInspections(List<InspectionResult> records) {
    final total = records.length;
    final passed = _count(records, InspectionStatus.passed);
    final failed = _count(records, InspectionStatus.failed);
    final underReview = _count(records, InspectionStatus.underReview);
    final defectCount = records.where((record) => record.defectDetected).length;
    final confidence = total == 0
        ? 0.0
        : records.fold<double>(0, (sum, record) => sum + record.confidence) /
              total;
    final milliseconds = total == 0
        ? 0
        : records.fold<int>(
                0,
                (sum, record) => sum + record.processingTime.inMilliseconds,
              ) ~/
              total;
    return ReportData(
      summary: ReportSummary(
        totalInspections: total,
        passedInspections: passed,
        failedInspections: failed,
        underReviewInspections: underReview,
        passRate: total == 0 ? 0 : passed / total * 100,
        averageConfidence: confidence * 100,
        averageProcessingTime: Duration(milliseconds: milliseconds),
        totalDefects: defectCount,
      ),
      defectDistribution: _defects(records),
      severityDistribution: _severity(records),
      inspectionTrend: _trend(records),
    );
  }

  static int _count(List<InspectionResult> records, InspectionStatus status) =>
      records.where((record) => record.status == status).length;

  static List<DefectDistribution> _defects(List<InspectionResult> records) {
    final counts = <String, int>{};
    for (final record in records) {
      final name = record.defectDetected
          ? record.defectType ?? 'Unclassified defect'
          : 'No Defect';
      counts[name] = (counts[name] ?? 0) + 1;
    }
    return _sort(counts)
        .map(
          (entry) => DefectDistribution(
            defectType: entry.key,
            count: entry.value,
            percentage: records.isEmpty ? 0 : entry.value / records.length * 100,
          ),
        )
        .toList();
  }

  static List<SeverityDistribution> _severity(List<InspectionResult> records) {
    final counts = <String, int>{};
    for (final record in records) {
      if (record.severity case final severity?) {
        counts[severity.label] = (counts[severity.label] ?? 0) + 1;
      }
    }
    final total = counts.values.fold<int>(0, (sum, count) => sum + count);
    return _sort(counts)
        .map(
          (entry) => SeverityDistribution(
            severity: entry.key,
            count: entry.value,
            percentage: total == 0 ? 0 : entry.value / total * 100,
          ),
        )
        .toList();
  }

  static List<InspectionTrendPoint> _trend(List<InspectionResult> records) {
    final groups = <DateTime, List<InspectionResult>>{};
    for (final record in records) {
      final day = DateTime(
        record.completedAt.year,
        record.completedAt.month,
        record.completedAt.day,
      );
      (groups[day] ??= <InspectionResult>[]).add(record);
    }
    final days = groups.keys.toList()..sort();
    return days.map((day) {
      final items = groups[day]!;
      return InspectionTrendPoint(
        label: '${day.month}/${day.day}',
        total: items.length,
        passed: _count(items, InspectionStatus.passed),
        failed: _count(items, InspectionStatus.failed),
        underReview: _count(items, InspectionStatus.underReview),
      );
    }).toList();
  }

  static List<MapEntry<String, int>> _sort(Map<String, int> counts) {
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }
}
