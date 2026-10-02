import '../../../inspection/domain/models/inspection_result.dart';
import '../../domain/repositories/inspection_history_repository.dart';
import 'demo_inspection_history_store.dart';

class DemoInspectionHistoryRepository implements InspectionHistoryRepository {
  DemoInspectionHistoryRepository(
    this._store, {
    this.delay = const Duration(milliseconds: 250),
  });

  final Duration delay;
  final DemoInspectionHistoryStore _store;

  @override
  Future<List<InspectionResult>> getHistory() async {
    await Future<void>.delayed(delay);
    return _store.records;
  }

  @override
  Future<InspectionResult?> getById(String inspectionId) async {
    await Future<void>.delayed(delay);
    return _store.byId(inspectionId);
  }

  @override
  Stream<List<InspectionResult>> watchHistory() async* {
    yield _store.records;
    yield* _store.changes;
  }
}
