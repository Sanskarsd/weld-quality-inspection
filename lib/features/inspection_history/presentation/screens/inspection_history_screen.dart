import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/controllers/inspection_history_controller.dart';
import '../../../inspection/domain/models/inspection_result.dart';
import '../widgets/history_records_view.dart';
import '../widgets/history_states.dart';

class InspectionHistoryScreen extends ConsumerWidget {
  const InspectionHistoryScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inspectionHistoryControllerProvider);
    final controller = ref.read(inspectionHistoryControllerProvider.notifier);
    final body = switch (state.phase) {
      HistoryPhase.loading => const Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: CircularProgressIndicator(),
        ),
      ),
      HistoryPhase.error => HistoryMessage(
        icon: Icons.error_outline,
        title: 'History unavailable',
        message: state.errorMessage!,
        action: FilledButton(
          onPressed: controller.load,
          child: const Text('Retry'),
        ),
      ),
      HistoryPhase.loaded when state.filteredRecords.isEmpty => HistoryMessage(
        icon: Icons.search_off_outlined,
        title: 'No inspections found',
        message: 'No inspection records match the current search and filter.',
        action: TextButton(
          onPressed: controller.clearFilters,
          child: const Text('Clear filters'),
        ),
      ),
      HistoryPhase.loaded => HistoryRecordsView(
        records: state.filteredRecords,
        onSelect: (record) =>
            context.go('/inspection-history/${record.inspectionId}'),
      ),
    };
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: controller.load,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: <Widget>[
            Text(
              'Inspection History',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Review previous weld and fabrication quality inspections.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final search = TextField(
                  onChanged: controller.setQuery,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    labelText: 'Search inspections',
                  ),
                );
                final filter = DropdownButtonFormField<InspectionStatus?>(
                  initialValue: state.filter,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: <DropdownMenuItem<InspectionStatus?>>[
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All statuses'),
                    ),
                    ...InspectionStatus.values.map(
                      (s) => DropdownMenuItem(value: s, child: Text(s.label)),
                    ),
                  ],
                  onChanged: controller.setFilter,
                );
                if (constraints.maxWidth < 600) {
                  return Column(
                    children: <Widget>[
                      search,
                      const SizedBox(height: 12),
                      filter,
                    ],
                  );
                }
                return Row(
                  children: <Widget>[
                    Expanded(flex: 2, child: search),
                    const SizedBox(width: 16),
                    Expanded(child: filter),
                    IconButton(
                      onPressed: controller.load,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh',
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            body,
          ],
        ),
      ),
    );
  }
}
