import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/inspection_request.dart';
import '../../domain/models/inspection_result.dart';
import '../providers/inspection_providers.dart';

enum InspectionPhase { idle, loading, success, error }

class NewInspectionState {
  const NewInspectionState({
    this.phase = InspectionPhase.idle,
    this.image,
    this.type = InspectionType.weldVisual,
    this.componentName = '',
    this.jobBatchId = '',
    this.notes = '',
    this.result,
    this.errorMessage,
  });

  final InspectionPhase phase;
  final InspectionImage? image;
  final InspectionType type;
  final String componentName;
  final String jobBatchId;
  final String notes;
  final InspectionResult? result;
  final String? errorMessage;

  bool get isLoading => phase == InspectionPhase.loading;

  NewInspectionState copyWith({
    InspectionPhase? phase,
    InspectionImage? image,
    InspectionType? type,
    String? componentName,
    String? jobBatchId,
    String? notes,
    InspectionResult? result,
    String? errorMessage,
    bool clearImage = false,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return NewInspectionState(
      phase: phase ?? this.phase,
      image: clearImage ? null : image ?? this.image,
      type: type ?? this.type,
      componentName: componentName ?? this.componentName,
      jobBatchId: jobBatchId ?? this.jobBatchId,
      notes: notes ?? this.notes,
      result: clearResult ? null : result ?? this.result,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class NewInspectionController extends Notifier<NewInspectionState> {
  @override
  NewInspectionState build() => const NewInspectionState();

  Future<void> selectImage() async {
    if (state.isLoading) {
      return;
    }

    try {
      final image = await ref.read(inspectionImagePickerProvider).pickImage();
      if (image != null) {
        state = state.copyWith(
          image: image,
          phase: InspectionPhase.idle,
          clearError: true,
          clearResult: true,
        );
      }
    } on Object {
      state = state.copyWith(
        phase: InspectionPhase.error,
        errorMessage:
            'Unable to select the inspection image. Please try again.',
      );
    }
  }

  void updateImage(InspectionImage image) {
    if (!state.isLoading) {
      state = state.copyWith(
        image: image,
        phase: InspectionPhase.idle,
        clearError: true,
        clearResult: true,
      );
    }
  }

  void removeImage() {
    if (!state.isLoading) {
      state = state.copyWith(
        phase: InspectionPhase.idle,
        clearImage: true,
        clearError: true,
        clearResult: true,
      );
    }
  }

  void updateType(InspectionType type) {
    state = state.copyWith(type: type, clearError: true);
  }

  void updateComponentName(String componentName) {
    state = state.copyWith(componentName: componentName, clearError: true);
  }

  void updateJobBatchId(String jobBatchId) {
    state = state.copyWith(jobBatchId: jobBatchId, clearError: true);
  }

  void updateNotes(String notes) {
    state = state.copyWith(notes: notes, clearError: true);
  }

  Future<void> runInspection() async {
    final image = state.image;
    if (image == null) {
      state = state.copyWith(
        phase: InspectionPhase.error,
        errorMessage:
            'Select an inspection image before running the inspection.',
        clearResult: true,
      );
      return;
    }
    if (state.componentName.trim().isEmpty) {
      state = state.copyWith(
        phase: InspectionPhase.error,
        errorMessage: 'Enter a component name before running the inspection.',
        clearResult: true,
      );
      return;
    }

    final request = InspectionRequest(
      image: image,
      type: state.type,
      componentName: state.componentName.trim(),
      jobBatchId: state.jobBatchId.trim().isEmpty
          ? null
          : state.jobBatchId.trim(),
      notes: state.notes.trim().isEmpty ? null : state.notes.trim(),
    );
    state = state.copyWith(
      phase: InspectionPhase.loading,
      clearError: true,
      clearResult: true,
    );

    try {
      final result = await ref
          .read(inspectionRepositoryProvider)
          .runInspection(request);
      state = state.copyWith(phase: InspectionPhase.success, result: result);
    } on Object {
      state = state.copyWith(
        phase: InspectionPhase.error,
        errorMessage:
            'The inspection could not be completed. Please try again.',
      );
    }
  }
}

final newInspectionControllerProvider =
    NotifierProvider<NewInspectionController, NewInspectionState>(
      NewInspectionController.new,
    );
