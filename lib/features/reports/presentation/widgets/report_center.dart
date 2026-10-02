import 'package:flutter/material.dart';

class ReportCenter extends StatelessWidget {
  const ReportCenter({
    required this.onSingleInspection,
    required this.onSummary,
    required this.onPeriodBatch,
    super.key,
  });

  final VoidCallback onSingleInspection;
  final VoidCallback onSummary;
  final VoidCallback onPeriodBatch;

  @override
  Widget build(BuildContext context) {
    final actions = <_ReportAction>[
      _ReportAction(
        title: 'Single Inspection Report',
        description: 'Generate a report for a specific inspection.',
        icon: Icons.description_outlined,
        onPressed: onSingleInspection,
      ),
      _ReportAction(
        title: 'Inspection Summary',
        description: 'Generate a summary of inspection results.',
        icon: Icons.summarize_outlined,
        onPressed: onSummary,
      ),
      _ReportAction(
        title: 'Period / Batch Report',
        description: 'Generate an analytical report for a selected group of inspections.',
        icon: Icons.date_range_outlined,
        onPressed: onPeriodBatch,
      ),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.folder_copy_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Report Center',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Prepare formal inspection documentation from the shared inspection record.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth >= 1050
                    ? (constraints.maxWidth - 32) / 3
                    : constraints.maxWidth >= 650
                    ? (constraints.maxWidth - 16) / 2
                    : constraints.maxWidth;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: actions
                      .map(
                        (action) => SizedBox(
                          width: width,
                          child: _ReportActionCard(action: action),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportAction {
  const _ReportAction({
    required this.title,
    required this.description,
    required this.icon,
    required this.onPressed,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onPressed;
}

class _ReportActionCard extends StatelessWidget {
  const _ReportActionCard({required this.action});

  final _ReportAction action;

  @override
  Widget build(BuildContext context) => Card(
    shape: RoundedRectangleBorder(
      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(action.icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(action.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(action.description),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: action.onPressed,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Prepare report'),
          ),
        ],
      ),
    ),
  );
}

