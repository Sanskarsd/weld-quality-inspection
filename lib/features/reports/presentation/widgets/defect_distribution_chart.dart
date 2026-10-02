import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../domain/models/report_data.dart';

class DefectDistributionChart extends StatelessWidget {
  const DefectDistributionChart({required this.distribution, super.key});

  final List<DefectDistribution> distribution;

  @override
  Widget build(BuildContext context) {
    final maxCount = distribution
        .fold<int>(0, (max, item) => item.count > max ? item.count : max)
        .toDouble();
    return SizedBox(
      height: 280,
      child: BarChart(
        BarChartData(
          maxY: maxCount + 3,
          alignment: BarChartAlignment.spaceAround,
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
                  if (index < 0 || index >= distribution.length) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      distribution[index].defectType.replaceAll(' ', '\n'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(
            distribution.length,
            (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: distribution[index].count.toDouble(),
                  color: Theme.of(context).colorScheme.primary,
                  width: 18,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
