import 'package:go_router/go_router.dart';

import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/inspection_history/presentation/screens/inspection_history_detail_screen.dart';
import '../../features/inspection_history/presentation/screens/inspection_history_screen.dart';
import '../../features/inspection/presentation/screens/new_inspection_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../shell/app_shell.dart';
import 'app_routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoute.dashboard.path,
  routes: <RouteBase>[
    GoRoute(path: '/', redirect: (context, state) => AppRoute.dashboard.path),
    ShellRoute(
      builder: (context, state, child) {
        return AppShell(location: state.uri.path, child: child);
      },
      routes: <RouteBase>[
        GoRoute(
          path: AppRoute.dashboard.path,
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: AppRoute.newInspection.path,
          builder: (context, state) => const NewInspectionScreen(),
        ),
        GoRoute(
          path: AppRoute.inspectionHistory.path,
          builder: (context, state) => const InspectionHistoryScreen(),
        ),
        GoRoute(
          path: '${AppRoute.inspectionHistory.path}/:inspectionId',
          builder: (context, state) => InspectionHistoryDetailScreen(
            inspectionId: state.pathParameters['inspectionId']!,
          ),
        ),
        GoRoute(
          path: AppRoute.reports.path,
          builder: (context, state) => const ReportsScreen(),
        ),
        GoRoute(
          path: AppRoute.settings.path,
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);
