import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../inspection_history/application/providers/inspection_history_providers.dart';
import '../../inspection/domain/models/inspection_result.dart';
import '../application/controllers/reports_controller.dart';
import '../domain/services/report_analytics_calculator.dart';
import '../domain/services/report_generator.dart';
import 'screens/report_preview_screen.dart';
import '../domain/models/report_data.dart';
import 'widgets/defect_distribution_chart.dart';
import 'widgets/inspection_trend_chart.dart';
import 'widgets/quality_insights.dart';
import 'widgets/report_center.dart';
import 'widgets/severity_distribution.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportsControllerProvider);
    final controller = ref.read(reportsControllerProvider.notifier);
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reports & Analysis',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Analyze inspection quality and prepare controlled report outputs.',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: controller.refresh,
                          tooltip: 'Refresh reports',
                          icon: const Icon(Icons.refresh),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    switch (state.phase) {
                      ReportsPhase.loading => const _LoadingState(),
                      ReportsPhase.error => _MessageState(
                        icon: Icons.error_outline,
                        title: 'Reports unavailable',
                        message: state.errorMessage!,
                        action: FilledButton(
                          onPressed: controller.load,
                          child: const Text('Retry'),
                        ),
                      ),
                      ReportsPhase.loaded
                          when state.data == null ||
                              state.data!.summary.totalInspections == 0 =>
                        const _MessageState(
                          icon: Icons.assessment_outlined,
                          title: 'No report data available',
                          message: 'Inspection analytics will appear after inspection data is available.',
                        ),
                      ReportsPhase.loaded => _ReportContent(data: state.data!),
                    },
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportContent extends ConsumerWidget {
  const _ReportContent({required this.data});
  final ReportData data;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defects = _Section(
      title: 'Defect Distribution',
      icon: Icons.bug_report_outlined,
      child: DefectDistributionChart(distribution: data.defectDistribution),
    );
    final severity = _Section(
      title: 'Severity Distribution',
      icon: Icons.warning_amber_outlined,
      child: SeverityDistributionView(distribution: data.severityDistribution),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AnalyticsHeading(summary: data.summary),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, c) => c.maxWidth >= 900
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: defects),
                    const SizedBox(width: 24),
                    Expanded(child: severity),
                  ],
                )
              : Column(
                  children: [defects, const SizedBox(height: 24), severity],
                ),
        ),
        const SizedBox(height: 24),
        _Section(
          title: 'Inspection Trend',
          icon: Icons.show_chart_outlined,
          child: InspectionTrendChart(points: data.inspectionTrend),
        ),
        const SizedBox(height: 24),
        _Section(
          title: 'Quality Insights',
          icon: Icons.lightbulb_outline,
          child: QualityInsights(data: data),
        ),
        const SizedBox(height: 24),
        ReportCenter(
          onSingleInspection: () => _selectSingle(context, ref),
          onSummary: () => _openSummary(context, ref),
          onPeriodBatch: () => _selectBatch(context, ref),
        ),
      ],
    );
  }

  Future<List<InspectionResult>> _records(WidgetRef ref) =>
      ref.read(inspectionHistoryRepositoryProvider).getHistory();

  Future<void> _openSummary(BuildContext context, WidgetRef ref) async {
    final records = await _records(ref);
    if (!context.mounted) return;
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => ReportPreviewScreen.summary(
        inspections: records,
        analytics: ReportAnalyticsCalculator.fromInspections(records),
      ),
    ));
  }

  Future<void> _selectSingle(BuildContext context, WidgetRef ref) async {
    final records = await _records(ref);
    if (!context.mounted) return;
    final selected = await showModalBottomSheet<InspectionResult>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(title: Text('Select inspection')),
            ...records.map((record) => ListTile(
              title: Text(record.inspectionId),
              subtitle: Text(record.componentName ?? record.imageName),
              trailing: Text(record.status.label),
              onTap: () => Navigator.pop(context, record),
            )),
          ],
        ),
      ),
    );
    if (selected != null && context.mounted) {
      await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => ReportPreviewScreen.single(inspection: selected),
      ));
    }
  }

  Future<void> _selectBatch(BuildContext context, WidgetRef ref) async {
    final records = await _records(ref);
    if (!context.mounted) return;
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'OPTIONAL DATE RANGE',
    );
    if (!context.mounted) return;
    final batches = records
        .map((record) => record.jobBatchId)
        .whereType<String>()
        .where((batch) => batch.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    final batch = await showModalBottomSheet<String?>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(title: Text('Select batch')), 
            ListTile(title: const Text('All inspection records'), onTap: () => Navigator.pop(context)),
            ...batches.map((item) => ListTile(title: Text(item), onTap: () => Navigator.pop(context, item))),
          ],
        ),
      ),
    );
    if (!context.mounted) return;
    final filter = ReportFilter(
      jobBatchId: batch,
      startDate: range?.start,
      endDate: range?.end,
    );
    final selected = filter.apply(records);
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => ReportPreviewScreen.periodBatch(
        inspections: selected,
        analytics: ReportAnalyticsCalculator.fromInspections(selected),
        filter: filter,
      ),
    ));
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.child,
  });
  final String title;
  final IconData icon;
  final Widget child;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    ),
  );
}

class _AnalyticsHeading extends StatelessWidget {
  const _AnalyticsHeading({required this.summary});

  final ReportSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 620;
            final metrics = <Widget>[
              _AnalyticalMetric(
                label: 'Defects identified',
                value: '${summary.totalDefects}',
                icon: Icons.report_problem_outlined,
              ),
              _AnalyticalMetric(
                label: 'Average confidence',
                value: '${summary.averageConfidence.toStringAsFixed(1)}%',
                icon: Icons.analytics_outlined,
              ),
              _AnalyticalMetric(
                label: 'Average processing time',
                value:
                    '${(summary.averageProcessingTime.inMilliseconds / 1000).toStringAsFixed(1)} s',
                icon: Icons.timer_outlined,
              ),
            ];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Inspection Analytics', style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  'Quality patterns, model performance, and process efficiency.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                compact
                    ? Column(
                        children: metrics
                            .map(
                              (metric) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: metric,
                              ),
                            )
                            .toList(),
                      )
                    : Row(
                        children: metrics
                            .map((metric) => Expanded(child: metric))
                            .toList(),
                      ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AnalyticalMetric extends StatelessWidget {
  const _AnalyticalMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 2),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    ],
  );
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(48),
    child: Center(child: CircularProgressIndicator()),
  );
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });
  final IconData icon;
  final String title, message;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(48),
    child: Center(
      child: Column(
        children: [
          Icon(icon, size: 48),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    ),
  );
}
