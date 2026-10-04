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
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) => Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              _ActionButton(icon: Icons.add_task_outlined, label: 'New Inspection', onPressed: onNewInspection, filled: true),
              _ActionButton(icon: Icons.history_outlined, label: 'Inspection History', onPressed: onHistory),
              _ActionButton(icon: Icons.assessment_outlined, label: 'Reports', onPressed: onReports),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.label, required this.onPressed, this.filled = false});
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool filled;
  @override
  Widget build(BuildContext context) => filled
      ? FilledButton.icon(onPressed: onPressed, icon: Icon(icon), label: Text(label))
      : OutlinedButton.icon(onPressed: onPressed, icon: Icon(icon), label: Text(label));
}
