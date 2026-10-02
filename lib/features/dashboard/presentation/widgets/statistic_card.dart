import 'package:flutter/material.dart';

class StatisticCard extends StatelessWidget {
  const StatisticCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.dataSourceLabel,
    super.key,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final String? dataSourceLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(label, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text('$value', style: theme.textTheme.headlineSmall),
                  if (dataSourceLabel case final label?) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(label, style: theme.textTheme.labelSmall),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
