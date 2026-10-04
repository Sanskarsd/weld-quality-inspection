import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../domain/models/report_data.dart';

class InspectionTrendChart extends StatelessWidget {
  const InspectionTrendChart({required this.points, super.key});
  final List<InspectionTrendPoint> points;
  @override
  Widget build(BuildContext context) {
    final maxY = points
        .fold<int>(0, (max, point) => point.total > max ? point.total : max)
        .toDouble();
    return Column(
      children: [
        SizedBox(
          height: 260,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: (points.length - 1).toDouble(),
              minY: 0,
              maxY: maxY + 5,
              gridData: const FlGridData(drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      return index >= 0 && index < points.length
                          ? Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(points[index].label),
                            )
                          : const SizedBox();
                    },
                  ),
                ),
              ),
              lineBarsData: [
                _line(
                  points,
                  (p) => p.total,
                  Theme.of(context).colorScheme.primary,
                ),
                _line(points, (p) => p.passed, Colors.green.shade700),
                _line(
                  points,
                  (p) => p.failed,
                  Theme.of(context).colorScheme.error,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 16,
          children: [
            _LegendItem(
              label: 'Total',
              color: Theme.of(context).colorScheme.primary,
            ),
            _LegendItem(label: 'Passed', color: Colors.green.shade700),
            _LegendItem(
              label: 'Failed',
              color: Theme.of(context).colorScheme.error,
            ),
          ],
        ),
      ],
    );
  }

  LineChartBarData _line(
    List<InspectionTrendPoint> items,
    int Function(InspectionTrendPoint) value,
    Color color,
  ) => LineChartBarData(
    color: color,
    barWidth: 2.5,
    isCurved: true,
    dotData: const FlDotData(show: true),
    belowBarData: BarAreaData(show: false),
    spots: List.generate(
      items.length,
      (index) => FlSpot(index.toDouble(), value(items[index]).toDouble()),
    ),
  );
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
