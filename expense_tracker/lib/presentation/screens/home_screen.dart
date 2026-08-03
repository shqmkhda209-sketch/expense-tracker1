import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_categories.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/action_button.dart';
import '../widgets/balance_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';
import 'transactions_list_screen.dart';

/// صفحه اصلی: نمایش موجودی کل، دکمه‌های سریع و آخرین تراکنش‌ها
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: txProvider.loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: txProvider.loadTransactions,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  BalanceCard(
                    balance: txProvider.totalBalance,
                    totalIncome: txProvider.totalIncome,
                    totalExpense: txProvider.totalExpense,
                    currency: settings.currency,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      ActionButton(
                        icon: Icons.add_circle_outline_rounded,
                        label: AppStrings.addIncome,
                        color: AppColors.income,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddTransactionScreen(type: TransactionType.income),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ActionButton(
                        icon: Icons.remove_circle_outline_rounded,
                        label: AppStrings.addExpense,
                        color: AppColors.expense,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddTransactionScreen(type: TransactionType.expense),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ActionButton(
                        icon: Icons.bar_chart_rounded,
                        label: AppStrings.reports,
                        color: Colors.blue,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ReportsScreen()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppStrings.recentTransactions,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      if (txProvider.all.isNotEmpty)
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const TransactionsListScreen()),
                          ),
                          child: const Text(AppStrings.seeAll),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (txProvider.all.isEmpty)
                    const EmptyState(
                      title: AppStrings.noTransactions,
                      subtitle: AppStrings.noTransactionsHint,
                    )
                  else
                    ...txProvider.recentTransactions.map(
                      (t) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TransactionTile(
                          transaction: t,
                          currency: settings.currency,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddTransactionScreen(type: t.type, editingTransaction: t),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
