import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/dashboard_data.dart';
import '../data/repositories/dashboard_repository.dart';

/// Central repository selection point. Replace only this implementation with
/// the future FastAPI-backed DashboardRepository; dashboard UI stays unchanged.
final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => const DemoDashboardRepository(),
);

/// Presentation consumes this data state, never a concrete repository.
final dashboardDataProvider = Provider<DashboardData>(
  (ref) => ref.watch(dashboardRepositoryProvider).getDashboardData(),
);
