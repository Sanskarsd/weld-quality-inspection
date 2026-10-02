import 'package:flutter/material.dart';

import '../../data/models/dashboard_data.dart';

class InspectionStatusSummary extends StatelessWidget {
  const InspectionStatusSummary({
    required this.summary,
    this.footerLabel,
    super.key,
  });

  final InspectionSummary summary;
  final String? footerLabel;

  @override
  Widget build(BuildContext context) {
    final total = summary.total == 0 ? 1 : summary.total;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            _StatusProgress(
              label: 'Passed',
              value: summary.passed,
              total: total,
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            _StatusProgress(
              label: 'Failed',
              value: summary.failed,
              total: total,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 20),
            _StatusProgress(
              label: 'Under review',
              value: summary.underReview,
              total: total,
              color: Colors.orange.shade800,
            ),
            if (footerLabel case final label?) ...<Widget>[
              const SizedBox(height: 16),
              Text(label, style: Theme.of(context).textTheme.labelSmall),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusProgress extends StatelessWidget {
  const _StatusProgress({
    required this.label,
    required this.value,
    required this.total,
    required this.color,
  });

  final String label;
  final int value;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: Text(label)),
            Text('$value of $total'),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value / total,
          color: color,
          minHeight: 10,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    );
  }
}
