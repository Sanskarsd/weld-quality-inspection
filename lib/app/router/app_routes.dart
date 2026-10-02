import 'package:flutter/material.dart';

enum AppRoute {
  dashboard('/dashboard', 'Dashboard', Icons.dashboard_outlined),
  newInspection('/new-inspection', 'New Inspection', Icons.add_task_outlined),
  inspectionHistory(
    '/inspection-history',
    'Inspection History',
    Icons.history_outlined,
  ),
  reports('/reports', 'Reports', Icons.assessment_outlined),
  settings('/settings', 'Settings', Icons.settings_outlined);

  const AppRoute(this.path, this.label, this.icon);

  final String path;
  final String label;
  final IconData icon;

  static AppRoute fromPath(String path) {
    return AppRoute.values.firstWhere(
      (route) => route.path == path,
      orElse: () => AppRoute.dashboard,
    );
  }
}
