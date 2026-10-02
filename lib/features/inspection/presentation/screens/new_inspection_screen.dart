import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/controllers/new_inspection_controller.dart';
import '../widgets/inspection_feedback.dart';
import '../widgets/inspection_image_input.dart';
import '../widgets/inspection_metadata_form.dart';
import '../widgets/inspection_result_card.dart';

class NewInspectionScreen extends ConsumerWidget {
  const NewInspectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(newInspectionControllerProvider);
    final controller = ref.read(newInspectionControllerProvider.notifier);
    final input = InspectionImageInput(
      image: state.image,
      isLoading: state.isLoading,
      onSelect: controller.selectImage,
      onRemove: controller.removeImage,
    );
    final metadata = InspectionMetadataForm(
      type: state.type,
      componentName: state.componentName,
      notes: state.notes,
      isLoading: state.isLoading,
      onTypeChanged: controller.updateType,
      onComponentNameChanged: controller.updateComponentName,
      onNotesChanged: controller.updateNotes,
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'New Inspection',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload a weld or fabrication image to begin an automated quality inspection.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 840) {
                      return Column(
                        children: <Widget>[
                          input,
                          const SizedBox(height: 20),
                          metadata,
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(child: input),
                        const SizedBox(width: 20),
                        Expanded(child: metadata),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: state.isLoading
                        ? null
                        : controller.runInspection,
                    icon: const Icon(Icons.play_circle_outline),
                    label: const Text('Run Inspection'),
                  ),
                ),
                if (state.phase == InspectionPhase.loading) ...<Widget>[
                  const SizedBox(height: 20),
                  const InspectionLoadingView(),
                ],
                if (state.phase == InspectionPhase.error &&
                    state.errorMessage != null) ...<Widget>[
                  const SizedBox(height: 20),
                  InspectionErrorView(message: state.errorMessage!),
                ],
                if (state.result != null) ...<Widget>[
                  const SizedBox(height: 24),
                  InspectionResultCard(result: state.result!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
