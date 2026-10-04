import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/dashboard_data.dart';
import '../data/repositories/dashboard_repository.dart';
import '../../inspection_history/application/providers/inspection_history_providers.dart';

/// Central repository selection point. Replace only this implementation with
/// the future FastAPI-backed DashboardRepository; dashboard UI stays unchanged.
final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) =>
      DemoDashboardRepository(ref.read(demoInspectionHistoryStoreProvider)),
);

/// Presentation consumes repository-provided state, never a concrete store.
final dashboardDataProvider = StreamProvider<DashboardData>((ref) async* {
  final repository = ref.watch(dashboardRepositoryProvider);
  yield await repository.getDashboardData();
  yield* repository.watchDashboardData();
});
