import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../domain/models/report_data.dart';

class InspectionOutcomeChart extends StatelessWidget {
  const InspectionOutcomeChart({required this.summary, super.key});
  final ReportSummary summary;
  @override
  Widget build(BuildContext context) {
    final values = <_Outcome>[
      _Outcome('Passed', summary.passedInspections, Colors.green.shade700),
      _Outcome(
        'Failed',
        summary.failedInspections,
        Theme.of(context).colorScheme.error,
      ),
      _Outcome(
        'Under Review',
        summary.underReviewInspections,
        Colors.orange.shade800,
      ),
    ];
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 42,
              sectionsSpace: 3,
              sections: values
                  .map(
                    (v) => PieChartSectionData(
                      value: v.value.toDouble(),
                      color: v.color,
                      title: '${v.value}',
                      radius: 48,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: values
              .map((v) => _LegendItem(label: v.label, color: v.color))
              .toList(),
        ),
      ],
    );
  }
}

class _Outcome {
  const _Outcome(this.label, this.value, this.color);
  final String label;
  final int value;
  final Color color;
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 10, height: 10, color: color),
      const SizedBox(width: 6),
      Text(label),
    ],
  );
}
