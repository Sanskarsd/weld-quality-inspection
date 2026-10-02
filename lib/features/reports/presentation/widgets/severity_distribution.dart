import 'package:flutter/material.dart';

import '../../domain/models/report_data.dart';

class SeverityDistributionView extends StatelessWidget {
  const SeverityDistributionView({required this.distribution, super.key});
  final List<SeverityDistribution> distribution;
  @override
  Widget build(BuildContext context) => Column(
    children: distribution.map((item) {
      final color = switch (item.severity) {
        'Low' => Colors.green.shade700,
        'Medium' => Colors.orange.shade700,
        'High' => Colors.deepOrange.shade700,
        _ => Theme.of(context).colorScheme.error,
      };
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 10, height: 10, color: color),
                const SizedBox(width: 8),
                Expanded(child: Text(item.severity)),
                Text('${item.count}  (${item.percentage.toStringAsFixed(1)}%)'),
              ],
            ),
            const SizedBox(height: 7),
            LinearProgressIndicator(
              value: item.percentage / 100,
              color: color,
              minHeight: 8,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        ),
      );
    }).toList(),
  );
}
