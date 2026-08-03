import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

/// نمودار میله‌ای مقایسه درآمد و هزینه در ۶ ماه اخیر
class MonthlyBarChart extends StatelessWidget {
  /// هر آیتم: (برچسب ماه, مجموع درآمد, مجموع هزینه)
  final List<(String, double, double)> data;

  const MonthlyBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty || data.every((d) => d.$2 == 0 && d.$3 == 0)) {
      return SizedBox(
        height: 200,
        child: Center(child: Text(AppStrings.noData, style: Theme.of(context).textTheme.bodyMedium)),
      );
    }

    final maxY = data
        .map((d) => d.$2 > d.$3 ? d.$2 : d.$3)
        .fold<double>(0, (a, b) => a > b ? a : b) * 1.2;

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          maxY: maxY == 0 ? 10 : maxY,
          alignment: BarChartAlignment.spaceAround,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(data[index].$1, style: Theme.of(context).textTheme.bodySmall),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(enabled: true),
          barGroups: List.generate(data.length, (i) {
            final (_, income, expense) = data[i];
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(toY: income, color: AppColors.income, width: 9, borderRadius: BorderRadius.circular(4)),
                BarChartRodData(toY: expense, color: AppColors.expense, width: 9, borderRadius: BorderRadius.circular(4)),
              ],
            );
          }),
        ),
      ),
    );
  }
}
