import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';

/// صفحه نمایش تمام تراکنش‌ها با امکان جستجو، فیلتر بر اساس نوع/دسته/تاریخ
/// و مرتب‌سازی
class TransactionsListScreen extends StatefulWidget {
  const TransactionsListScreen({super.key});

  @override
  State<TransactionsListScreen> createState() => _TransactionsListScreenState();
}

class _TransactionsListScreenState extends State<TransactionsListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteConfirmTitle),
        content: const Text(AppStrings.deleteConfirmMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text(AppStrings.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(AppStrings.delete, style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<TransactionProvider>().deleteTransaction(id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.deletedSuccessfully)),
        );
      }
    }
  }

  void _openFilterSheet(BuildContext context) {
    final provider = context.read<TransactionProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FilterSheet(provider: provider),
    );
  }

  void _openSortSheet(BuildContext context) {
    final provider = context.read<TransactionProvider>();
    showModalBottomSheet(
      context: context,
      builder: (context) => _SortSheet(provider: provider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final settings = context.watch<SettingsProvider>();
    final list = provider.filteredTransactions;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.allTransactions)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: provider.setSearchQuery,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: AppStrings.search,
                      prefixIcon: const Icon(Icons.search_rounded),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _RoundIconButton(
                  icon: Icons.filter_list_rounded,
                  onTap: () => _openFilterSheet(context),
                  active: provider.filter != TransactionFilter.all ||
                      provider.dateRange != null ||
                      provider.categoryFilter != null,
                ),
                const SizedBox(width: 8),
                _RoundIconButton(
                  icon: Icons.sort_rounded,
                  onTap: () => _openSortSheet(context),
                  active: provider.sort != TransactionSort.newest,
                ),
              ],
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? const Center(
                    child: EmptyState(
                      title: AppStrings.noTransactions,
                      subtitle: AppStrings.noTransactionsHint,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final t = list[index];
                      return TransactionTile(
                        transaction: t,
                        currency: settings.currency,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddTransactionScreen(type: t.type, editingTransaction: t),
                          ),
                        ),
                        onDelete: () => _confirmDelete(context, t.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  const _RoundIconButton({required this.icon, required this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withOpacity(0.12) : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: active ? AppColors.primary : Theme.of(context).dividerColor),
        ),
        child: Icon(icon, size: 20, color: active ? AppColors.primary : null),
      ),
    );
  }
}

/// شیت پایین صفحه برای فیلتر بر اساس نوع، دسته‌بندی و بازه تاریخ
class _FilterSheet extends StatefulWidget {
  final TransactionProvider provider;
  const _FilterSheet({required this.provider});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late TransactionFilter _filter;
  late String? _category;
  DateTimeRange? _range;

  @override
  void initState() {
    super.initState();
    _filter = widget.provider.filter;
    _category = widget.provider.categoryFilter;
    _range = widget.provider.dateRange;
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.provider.allCategories;

    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(AppStrings.filter, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text(AppStrings.all),
                selected: _filter == TransactionFilter.all,
                onSelected: (_) => setState(() => _filter = TransactionFilter.all),
              ),
              ChoiceChip(
                label: const Text(AppStrings.incomeOnly),
                selected: _filter == TransactionFilter.incomeOnly,
                onSelected: (_) => setState(() => _filter = TransactionFilter.incomeOnly),
              ),
              ChoiceChip(
                label: const Text(AppStrings.expenseOnly),
                selected: _filter == TransactionFilter.expenseOnly,
                onSelected: (_) => setState(() => _filter = TransactionFilter.expenseOnly),
              ),
            ],
          ),
          if (categories.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(AppStrings.category, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((c) {
                return ChoiceChip(
                  label: Text(c),
                  selected: _category == c,
                  onSelected: (selected) => setState(() => _category = selected ? c : null),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.date_range_outlined),
            label: Text(_range == null
                ? AppStrings.date
                : '${_range!.start.year}/${_range!.start.month}/${_range!.start.day} - ${_range!.end.year}/${_range!.end.month}/${_range!.end.day}'),
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2015),
                lastDate: DateTime(2035),
              );
              if (picked != null) setState(() => _range = picked);
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.provider.clearFilters();
                    Navigator.pop(context);
                  },
                  child: const Text(AppStrings.cancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.provider.setFilter(_filter);
                    widget.provider.setCategoryFilter(_category);
                    widget.provider.setDateRange(_range);
                    Navigator.pop(context);
                  },
                  child: const Text(AppStrings.filter),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// شیت پایین صفحه برای انتخاب حالت مرتب‌سازی
class _SortSheet extends StatelessWidget {
  final TransactionProvider provider;
  const _SortSheet({required this.provider});

  @override
  Widget build(BuildContext context) {
    final options = {
      TransactionSort.newest: AppStrings.newestFirst,
      TransactionSort.oldest: AppStrings.oldestFirst,
      TransactionSort.highestAmount: AppStrings.highestAmount,
      TransactionSort.lowestAmount: AppStrings.lowestAmount,
    };

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.entries.map((e) {
            final isSelected = provider.sort == e.key;
            return ListTile(
              title: Text(e.value, textAlign: TextAlign.right),
              trailing: isSelected ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
              onTap: () {
                provider.setSort(e.key);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
