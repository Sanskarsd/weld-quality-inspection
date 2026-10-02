import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weld_inspection_app/features/inspection/application/controllers/new_inspection_controller.dart';
import 'package:weld_inspection_app/features/inspection/application/providers/inspection_providers.dart';
import 'package:weld_inspection_app/features/inspection/data/repositories/demo_inspection_repository.dart';
import 'package:weld_inspection_app/features/inspection/domain/models/inspection_request.dart';
import 'package:weld_inspection_app/features/inspection/domain/models/inspection_result.dart';
import 'package:weld_inspection_app/features/inspection/domain/repositories/inspection_repository.dart';
import 'package:weld_inspection_app/features/inspection_history/data/repositories/demo_inspection_history_store.dart';

void main() {
  InspectionImage image() => InspectionImage(
    fileName: 'sample-weld.jpg',
    bytes: Uint8List.fromList(<int>[1, 2, 3]),
  );

  InspectionResult result() => InspectionResult(
    inspectionId: 'TEST-001',
    status: InspectionStatus.passed,
    confidence: 0.95,
    defectDetected: false,
    processingTime: const Duration(milliseconds: 1),
    completedAt: DateTime(2026),
    imageName: 'sample-weld.jpg',
    dataSource: InspectionDataSource.live,
  );

  test('demo repository fulfils the inspection contract', () async {
    final InspectionRepository repository = DemoInspectionRepository(
      DemoInspectionHistoryStore(),
      processingDelay: Duration.zero,
    );

    final inspectionResult = await repository.runInspection(
      InspectionRequest(
        image: image(),
        type: InspectionType.weldVisual,
        componentName: 'Pressure Vessel Shell',
      ),
    );

    expect(inspectionResult.inspectionId, isNotEmpty);
    expect(inspectionResult.confidence, inInclusiveRange(0.0, 1.0));
    expect(inspectionResult.dataSource, InspectionDataSource.demo);
  });

  test('controller validates the selected image before submission', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container
        .read(newInspectionControllerProvider.notifier)
        .runInspection();

    final state = container.read(newInspectionControllerProvider);
    expect(state.phase, InspectionPhase.error);
    expect(state.errorMessage, isNotNull);
  });

  test('controller requires a component name before submission', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(newInspectionControllerProvider.notifier);
    controller.updateImage(image());

    await controller.runInspection();

    expect(
      container.read(newInspectionControllerProvider).phase,
      InspectionPhase.error,
    );
    expect(
      container.read(newInspectionControllerProvider).errorMessage,
      contains('component name'),
    );
  });

  test('controller exposes loading then success state', () async {
    final completer = Completer<InspectionResult>();
    final container = ProviderContainer(
      overrides: [
        inspectionRepositoryProvider.overrideWithValue(
          _CompletingRepository(completer.future),
        ),
      ],
    );
    addTearDown(container.dispose);
    final controller = container.read(newInspectionControllerProvider.notifier);
    controller.updateImage(image());
    controller.updateComponentName('Pressure Vessel Shell');

    final operation = controller.runInspection();
    expect(
      container.read(newInspectionControllerProvider).phase,
      InspectionPhase.loading,
    );
    completer.complete(result());
    await operation;

    final state = container.read(newInspectionControllerProvider);
    expect(state.phase, InspectionPhase.success);
    expect(state.result?.inspectionId, 'TEST-001');
  });

  test(
    'controller exposes an error state when repository operation fails',
    () async {
      final container = ProviderContainer(
        overrides: [
          inspectionRepositoryProvider.overrideWithValue(
            const _FailingRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(
        newInspectionControllerProvider.notifier,
      );
      controller.updateImage(image());
      controller.updateComponentName('Pressure Vessel Shell');

      await controller.runInspection();

      final state = container.read(newInspectionControllerProvider);
      expect(state.phase, InspectionPhase.error);
      expect(state.errorMessage, isNotNull);
    },
  );
}

class _CompletingRepository implements InspectionRepository {
  const _CompletingRepository(this.result);

  final Future<InspectionResult> result;

  @override
  Future<InspectionResult> runInspection(InspectionRequest request) => result;
}

class _FailingRepository implements InspectionRepository {
  const _FailingRepository();

  @override
  Future<InspectionResult> runInspection(InspectionRequest request) {
    throw StateError('Repository failure');
  }
}
