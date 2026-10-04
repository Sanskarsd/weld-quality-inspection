import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../inspection/domain/models/inspection_result.dart';
import '../providers/inspection_history_providers.dart';

enum HistoryPhase { loading, loaded, error }

class InspectionHistoryState {
  const InspectionHistoryState({
    this.phase = HistoryPhase.loading,
    this.records = const <InspectionResult>[],
    this.query = '',
    this.filter,
    this.errorMessage,
  });
  final HistoryPhase phase;
  final List<InspectionResult> records;
  final String query;
  final InspectionStatus? filter;
  final String? errorMessage;
  List<InspectionResult> get filteredRecords => records.where((record) {
    final queryMatches =
        query.isEmpty ||
        '${record.inspectionId} ${record.status.label} ${record.defectType ?? ''}'
            .toLowerCase()
            .contains(query.toLowerCase());
    return queryMatches && (filter == null || record.status == filter);
  }).toList();
  InspectionHistoryState copyWith({
    HistoryPhase? phase,
    List<InspectionResult>? records,
    String? query,
    InspectionStatus? filter,
    String? errorMessage,
    bool clearFilter = false,
  }) => InspectionHistoryState(
    phase: phase ?? this.phase,
    records: records ?? this.records,
    query: query ?? this.query,
    filter: clearFilter ? null : filter ?? this.filter,
    errorMessage: errorMessage,
  );
}

class InspectionHistoryController extends Notifier<InspectionHistoryState> {
  @override
  InspectionHistoryState build() {
    final subscription = ref
        .read(inspectionHistoryRepositoryProvider)
        .watchHistory()
        .listen((records) {
          if (ref.mounted) {
            state = state.copyWith(
              phase: HistoryPhase.loaded,
              records: records,
            );
          }
        });
    ref.onDispose(subscription.cancel);
    Future<void>.microtask(load);
    return const InspectionHistoryState();
  }

  Future<void> load() async {
    state = state.copyWith(phase: HistoryPhase.loading, errorMessage: null);
    try {
      final records = await ref
          .read(inspectionHistoryRepositoryProvider)
          .getHistory();
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(phase: HistoryPhase.loaded, records: records);
    } on Object {
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        phase: HistoryPhase.error,
        errorMessage: 'Unable to load inspection history. Please try again.',
      );
    }
  }

  void setQuery(String query) => state = state.copyWith(query: query);
  void setFilter(InspectionStatus? filter) =>
      state = state.copyWith(filter: filter, clearFilter: filter == null);
  void clearFilters() => state = state.copyWith(query: '', clearFilter: true);
}

final inspectionHistoryControllerProvider =
    NotifierProvider<InspectionHistoryController, InspectionHistoryState>(
      InspectionHistoryController.new,
    );

final inspectionDetailProvider =
    FutureProvider.family<InspectionResult?, String>(
      (ref, inspectionId) =>
          ref.read(inspectionHistoryRepositoryProvider).getById(inspectionId),
    );
