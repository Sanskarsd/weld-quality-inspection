import 'package:flutter/material.dart';

import '../../domain/models/report_data.dart';

class QualityInsights extends StatelessWidget {
  const QualityInsights({required this.data, super.key});
  final ReportData data;
  @override
  Widget build(BuildContext context) {
    final items = <_InsightItem>[
      if (data.defectDistribution.isNotEmpty)
        _InsightItem(
          Icons.bug_report_outlined,
          'Most common defect: ${_mostCommonDefect(data).defectType}',
        ),
      if (data.severityDistribution.isNotEmpty)
        _InsightItem(
          Icons.warning_amber_outlined,
          'Most frequent severity: ${_mostFrequentSeverity(data).severity}',
        ),
      _InsightItem(
        Icons.verified_outlined,
        'Pass rate: ${data.summary.passRate.toStringAsFixed(1)}%',
      ),
      _InsightItem(
        Icons.analytics_outlined,
        'Average AI confidence: ${data.summary.averageConfidence.toStringAsFixed(1)}%',
      ),
      _InsightItem(
        Icons.timer_outlined,
        'Average processing time: ${(data.summary.averageProcessingTime.inMilliseconds / 1000).toStringAsFixed(1)} seconds',
      ),
    ];
    return Column(
      children: items
          .map(
            (item) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(item.icon),
              title: Text(item.message),
            ),
          )
          .toList(),
    );
  }

  DefectDistribution _mostCommonDefect(ReportData data) =>
      data.defectDistribution.reduce((a, b) => a.count >= b.count ? a : b);

  SeverityDistribution _mostFrequentSeverity(ReportData data) =>
      data.severityDistribution.reduce((a, b) => a.count >= b.count ? a : b);
}

class _InsightItem {
  const _InsightItem(this.icon, this.message);

  final IconData icon;
  final String message;
}
