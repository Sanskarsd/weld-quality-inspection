import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weld_inspection_app/features/inspection/domain/models/inspection_result.dart';
import 'package:weld_inspection_app/features/inspection_history/application/controllers/inspection_history_controller.dart';
import 'package:weld_inspection_app/features/inspection_history/application/providers/inspection_history_providers.dart';
import 'package:weld_inspection_app/features/inspection_history/data/repositories/demo_inspection_history_repository.dart';
import 'package:weld_inspection_app/features/inspection_history/data/repositories/demo_inspection_history_store.dart';
import 'package:weld_inspection_app/features/inspection_history/domain/repositories/inspection_history_repository.dart';

void main() {
  test('demo history repository returns valid records', () async {
    final records = await DemoInspectionHistoryRepository(
      DemoInspectionHistoryStore(),
      delay: Duration.zero,
    ).getHistory();
    expect(records, isNotEmpty);
    expect(records.every((record) => record.inspectionId.isNotEmpty), isTrue);
  });

  test(
    'controller loads, searches, filters, and handles empty results',
    () async {
      final container = ProviderContainer(
        overrides: [
          inspectionHistoryRepositoryProvider.overrideWithValue(
            DemoInspectionHistoryRepository(
              DemoInspectionHistoryStore(),
              delay: Duration.zero,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(
        inspectionHistoryControllerProvider.notifier,
      );
      expect(
        container.read(inspectionHistoryControllerProvider).phase,
        HistoryPhase.loading,
      );
      await controller.load();
      controller.setQuery('crack');
      controller.setFilter(InspectionStatus.failed);
      expect(
        container.read(inspectionHistoryControllerProvider).filteredRecords,
        hasLength(1),
      );
      controller.setFilter(InspectionStatus.passed);
      expect(
        container.read(inspectionHistoryControllerProvider).filteredRecords,
        isEmpty,
      );
    },
  );

  test('controller exposes an error when history loading fails', () async {
    final container = ProviderContainer(
      overrides: [
        inspectionHistoryRepositoryProvider.overrideWithValue(
          const _FailingHistoryRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container.read(inspectionHistoryControllerProvider.notifier).load();
    expect(
      container.read(inspectionHistoryControllerProvider).phase,
      HistoryPhase.error,
    );
  });
}

class _FailingHistoryRepository implements InspectionHistoryRepository {
  const _FailingHistoryRepository();
  @override
  Future<List<InspectionResult>> getHistory() async =>
      throw StateError('failed');
  @override
  Future<InspectionResult?> getById(String inspectionId) async =>
      throw StateError('failed');
  @override
  Stream<List<InspectionResult>> watchHistory() =>
      const Stream<List<InspectionResult>>.empty();
}
