import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../application/dashboard_providers.dart';
import '../data/models/dashboard_data.dart';
import 'widgets/dashboard_section.dart';
import 'widgets/inspection_status_summary.dart';
import 'widgets/quick_actions.dart';
import 'widgets/recent_inspections.dart';
import 'widgets/statistic_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardData = ref.watch(dashboardDataProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _DashboardHeader(
                  dataSourceNotice: dashboardData.dataSourceNotice,
                ),
                const SizedBox(height: 24),
                _SummaryCards(
                  summary: dashboardData.summary,
                  dataSourceLabel: dashboardData.dataSourceNotice,
                ),
                const SizedBox(height: 24),
                DashboardSection(
                  title: 'Quick actions',
                  child: QuickActions(
                    onNewInspection: () =>
                        context.go(AppRoute.newInspection.path),
                    onHistory: () =>
                        context.go(AppRoute.inspectionHistory.path),
                    onReports: () => context.go(AppRoute.reports.path),
                  ),
                ),
                const SizedBox(height: 32),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final statusSummary = DashboardSection(
                      title: 'Inspection status',
                      child: InspectionStatusSummary(
                        summary: dashboardData.summary,
                        footerLabel: dashboardData.statusSummaryNote,
                      ),
                    );
                    final recentInspections = DashboardSection(
                      title: 'Recent inspections',
                      action: _DataSourceLabel(
                        label: dashboardData.dataSourceNotice,
                      ),
                      child: RecentInspections(
                        inspections: dashboardData.recentInspections,
                      ),
                    );

                    if (constraints.maxWidth < 1050) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          statusSummary,
                          const SizedBox(height: 32),
                          recentInspections,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(flex: 2, child: recentInspections),
                        const SizedBox(width: 24),
                        Expanded(child: statusSummary),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.dataSourceNotice});

  final String? dataSourceNotice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Weld Inspection Dashboard',
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Monitor weld and fabrication quality inspection activity for process equipment manufacturing.',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 12),
        _DataSourceLabel(label: dataSourceNotice),
      ],
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.summary, required this.dataSourceLabel});

  final InspectionSummary summary;
  final String? dataSourceLabel;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      StatisticCard(
        label: 'Total inspections',
        value: summary.total,
        icon: Icons.fact_check_outlined,
        color: Theme.of(context).colorScheme.primary,
        dataSourceLabel: dataSourceLabel,
      ),
      StatisticCard(
        label: 'Inspections passed',
        value: summary.passed,
        icon: Icons.check_circle_outline,
        color: Colors.green,
        dataSourceLabel: dataSourceLabel,
      ),
      StatisticCard(
        label: 'Inspections failed',
        value: summary.failed,
        icon: Icons.error_outline,
        color: Theme.of(context).colorScheme.error,
        dataSourceLabel: dataSourceLabel,
      ),
      StatisticCard(
        label: 'Pending / under review',
        value: summary.underReview,
        icon: Icons.pending_actions_outlined,
        color: Colors.orange.shade800,
        dataSourceLabel: dataSourceLabel,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1180
            ? 4
            : constraints.maxWidth >= 760
            ? 2
            : 1;
        const gap = 16.0;
        final cardWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: cards
              .map((card) => SizedBox(width: cardWidth, child: card))
              .toList(),
        );
      },
    );
  }
}

class _DataSourceLabel extends StatelessWidget {
  const _DataSourceLabel({required this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    if (label == null) {
      return const SizedBox.shrink();
    }

    return Chip(
      avatar: const Icon(Icons.info_outline, size: 18),
      label: Text(label!),
      visualDensity: VisualDensity.compact,
    );
  }
}
