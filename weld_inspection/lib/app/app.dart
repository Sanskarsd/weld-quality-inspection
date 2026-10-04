import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/settings/application/controllers/settings_controller.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class WeldInspectionApp extends ConsumerWidget {
  const WeldInspectionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode =
        ref.watch(settingsControllerProvider).value?.themeMode ?? ThemeMode.system;
    return MaterialApp.router(
      title: 'Weld Inspection System',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
