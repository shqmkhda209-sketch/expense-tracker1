import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/currency_formatter.dart';

/// نمودار دایره‌ای نمایش سهم هر دسته از کل هزینه‌ها
class ExpensePieChart extends StatefulWidget {
  final Map<String, double> data;
  final CurrencyType currency;

  const ExpensePieChart({super.key, required this.data, required this.currency});

  @override
  State<ExpensePieChart> createState() => _ExpensePieChartState();
}

class _ExpensePieChartState extends State<ExpensePieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Text(AppStrings.noData, style: Theme.of(context).textTheme.bodyMedium),
        ),
      );
    }

    final entries = widget.data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold(0.0, (sum, e) => sum + e.value);

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 48,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex = response.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sections: List.generate(entries.length, (i) {
                final isTouched = i == _touchedIndex;
                final percent = (entries[i].value / total * 100);
                return PieChartSectionData(
                  color: AppColors.chartColors[i % AppColors.chartColors.length],
                  value: entries[i].value,
                  title: '${percent.toStringAsFixed(0)}%',
                  radius: isTouched ? 56 : 48,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 14,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: List.generate(entries.length, (i) {
            final color = AppColors.chartColors[i % AppColors.chartColors.length];
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text('${entries[i].key} · ${CurrencyFormatter.format(entries[i].value, widget.currency)}',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            );
          }),
        ),
      ],
    );
  }
}
