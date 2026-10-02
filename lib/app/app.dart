import 'package:flutter/material.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';

class WeldInspectionApp extends StatelessWidget {
  const WeldInspectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Weld Inspection System',
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
