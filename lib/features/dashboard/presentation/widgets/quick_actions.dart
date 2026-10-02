import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({
    required this.onNewInspection,
    required this.onHistory,
    required this.onReports,
    super.key,
  });

  final VoidCallback onNewInspection;
  final VoidCallback onHistory;
  final VoidCallback onReports;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            FilledButton.icon(
              onPressed: onNewInspection,
              icon: const Icon(Icons.add_task_outlined),
              label: const Text('New Inspection'),
            ),
            OutlinedButton.icon(
              onPressed: onHistory,
              icon: const Icon(Icons.history_outlined),
              label: const Text('Inspection History'),
            ),
            OutlinedButton.icon(
              onPressed: onReports,
              icon: const Icon(Icons.assessment_outlined),
              label: const Text('Reports'),
            ),
          ],
        ),
      ),
    );
  }
}
