import 'package:flutter/material.dart';

import '../../../inspection/domain/models/inspection_result.dart';

class HistoryStatusBadge extends StatelessWidget {
  const HistoryStatusBadge({required this.status, super.key});
  final InspectionStatus status;
  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      InspectionStatus.passed => Colors.green,
      InspectionStatus.failed => Theme.of(context).colorScheme.error,
      InspectionStatus.underReview => Colors.orange.shade800,
    };
    return Chip(
      label: Text(status.label),
      visualDensity: VisualDensity.compact,
      side: BorderSide.none,
      backgroundColor: color.withValues(alpha: .12),
      labelStyle: TextStyle(color: color),
    );
  }
}
