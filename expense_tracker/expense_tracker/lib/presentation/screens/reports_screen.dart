import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/currency_formatter.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/expense_pie_chart.dart';
import '../widgets/monthly_bar_chart.dart';
import '../widgets/stat_card.dart';

/// صفحه گزارش‌ها: خلاصه ماه جاری، نمودار دایره‌ای هزینه‌ها،
/// نمودار میله‌ای ماهانه و پردرآمدترین/پرهزینه‌ترین دسته‌ها
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final settings = context.watch<SettingsProvider>();
    final currency = settings.currency;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.reports)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: AppStrings.monthlyIncome,
                  value: CurrencyFormatter.format(provider.monthlyIncome, currency),
                  icon: Icons.arrow_downward_rounded,
                  color: AppColors.income,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  label: AppStrings.monthlyExpense,
                  value: CurrencyFormatter.format(provider.monthlyExpense, currency),
                  icon: Icons.arrow_upward_rounded,
                  color: AppColors.expense,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          StatCard(
            label: AppStrings.monthlyBalance,
            value: CurrencyFormatter.format(provider.monthlyBalance, currency),
            icon: Icons.account_balance_wallet_outlined,
            color: provider.monthlyBalance >= 0 ? AppColors.income : AppColors.expense,
          ),
          const SizedBox(height: 28),
          _SectionCard(
            title: AppStrings.expenseByCategory,
            child: ExpensePieChart(data: provider.expenseByCategory, currency: currency),
          ),
          const SizedBox(height: 20),
          _SectionCard(
            title: AppStrings.monthlyChart,
            child: Column(
              children: [
                MonthlyBarChart(data: provider.monthlyChartData),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LegendDot(color: AppColors.income, label: AppStrings.totalIncome),
                    const SizedBox(width: 16),
                    _LegendDot(color: AppColors.expense, label: AppStrings.totalExpense),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _TopCategoryCard(
                  title: AppStrings.topExpenseCategory,
                  category: provider.topExpenseCategory,
                  color: AppColors.expense,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TopCategoryCard(
                  title: AppStrings.topIncomeCategory,
                  category: provider.topIncomeCategory,
                  color: AppColors.income,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _TopCategoryCard extends StatelessWidget {
  final String title;
  final String? category;
  final Color color;
  const _TopCategoryCard({required this.title, required this.category, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.right),
          const SizedBox(height: 8),
          Text(
            category ?? '—',
            style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
