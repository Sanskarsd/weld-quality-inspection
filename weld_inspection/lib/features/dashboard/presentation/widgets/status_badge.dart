import 'package:flutter/material.dart';

import '../../data/models/dashboard_data.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.status, super.key});

  final InspectionStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      InspectionStatus.passed => Colors.green,
      InspectionStatus.failed => Theme.of(context).colorScheme.error,
      InspectionStatus.underReview => Colors.orange.shade800,
    };
    final label = switch (status) {
      InspectionStatus.passed => 'Passed',
      InspectionStatus.failed => 'Failed',
      InspectionStatus.underReview => 'Under review',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: ShapeDecoration(
        color: color.withValues(alpha: 0.12),
        shape: const StadiumBorder(),
      ),
      child: Text(label, style: TextStyle(color: color)),
    );
  }
}
