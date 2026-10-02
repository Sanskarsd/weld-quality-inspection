import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/demo_inspection_history_repository.dart';
import '../../data/repositories/demo_inspection_history_store.dart';
import '../../domain/repositories/inspection_history_repository.dart';

/// The single central switch point for the future FastAPI repository.
final demoInspectionHistoryStoreProvider = Provider<DemoInspectionHistoryStore>(
  (ref) {
    final store = DemoInspectionHistoryStore();
    ref.onDispose(store.dispose);
    return store;
  },
);

final inspectionHistoryRepositoryProvider =
    Provider<InspectionHistoryRepository>(
      (ref) => DemoInspectionHistoryRepository(
        ref.read(demoInspectionHistoryStoreProvider),
      ),
    );
