import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/report_data.dart';
import '../providers/reports_providers.dart';

enum ReportsPhase { loading, loaded, error }

class ReportsState {
  const ReportsState({
    this.phase = ReportsPhase.loading,
    this.data,
    this.errorMessage,
  });
  final ReportsPhase phase;
  final ReportData? data;
  final String? errorMessage;
}

class ReportsController extends Notifier<ReportsState> {
  @override
  ReportsState build() {
    final subscription = ref
        .read(reportsRepositoryProvider)
        .watchReportData()
        .listen((data) {
          if (ref.mounted) {
            state = ReportsState(phase: ReportsPhase.loaded, data: data);
          }
        });
    ref.onDispose(subscription.cancel);
    Future<void>.microtask(load);
    return const ReportsState();
  }

  Future<void> load() async {
    state = const ReportsState(phase: ReportsPhase.loading);
    try {
      final data = await ref.read(reportsRepositoryProvider).getReportData();
      if (ref.mounted) {
        state = ReportsState(phase: ReportsPhase.loaded, data: data);
      }
    } on Object {
      if (ref.mounted) {
        state = const ReportsState(
          phase: ReportsPhase.error,
          errorMessage: 'Unable to load inspection reports. Please try again.',
        );
      }
    }
  }

  Future<void> refresh() => load();
}

final reportsControllerProvider =
    NotifierProvider<ReportsController, ReportsState>(ReportsController.new);
