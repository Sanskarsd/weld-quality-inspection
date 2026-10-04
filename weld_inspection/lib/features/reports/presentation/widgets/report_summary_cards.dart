import 'package:flutter/material.dart';

import '../../domain/models/report_data.dart';

class ReportSummaryCards extends StatelessWidget {
  const ReportSummaryCards({required this.summary, super.key});
  final ReportSummary summary;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final cards = <_KpiData>[
      _KpiData(
        'Total Inspections',
        '${summary.totalInspections}',
        Icons.fact_check_outlined,
        colors.primary,
      ),
      _KpiData(
        'Passed',
        '${summary.passedInspections}',
        Icons.check_circle_outline,
        Colors.green.shade700,
      ),
      _KpiData(
        'Failed',
        '${summary.failedInspections}',
        Icons.error_outline,
        colors.error,
      ),
      _KpiData(
        'Under Review',
        '${summary.underReviewInspections}',
        Icons.pending_actions_outlined,
        Colors.orange.shade800,
      ),
      _KpiData(
        'Pass Rate',
        '${summary.passRate.toStringAsFixed(1)}%',
        Icons.task_alt_outlined,
        colors.primary,
      ),
      _KpiData(
        'Average Confidence',
        '${summary.averageConfidence.toStringAsFixed(1)}%',
        Icons.analytics_outlined,
        Colors.teal.shade700,
      ),
      _KpiData(
        'Avg. Processing Time',
        '${(summary.averageProcessingTime.inMilliseconds / 1000).toStringAsFixed(1)}s',
        Icons.timer_outlined,
        Colors.blueGrey.shade700,
      ),
      _KpiData(
        'Total Defects',
        '${summary.totalDefects}',
        Icons.report_problem_outlined,
        Colors.deepOrange.shade700,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1180
            ? 4
            : constraints.maxWidth >= 640
            ? 2
            : 1;
        const gap = 16.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: cards
              .map(
                (item) => SizedBox(
                  width: width,
                  child: _KpiCard(data: item),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _KpiData {
  const _KpiData(this.label, this.value, this.icon, this.color);
  final String label, value;
  final IconData icon;
  final Color color;
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.data});
  final _KpiData data;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: data.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.label, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  data.value,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
