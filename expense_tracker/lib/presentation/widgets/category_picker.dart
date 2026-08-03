import 'package:flutter/material.dart';
import '../../core/constants/app_categories.dart';
import '../../core/constants/app_colors.dart';

/// ویجت شبکه‌ای برای انتخاب دسته‌بندی درآمد یا هزینه
class CategoryPicker extends StatelessWidget {
  final TransactionType type;
  final String? selected;
  final ValueChanged<String> onSelect;

  const CategoryPicker({
    super.key,
    required this.type,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final categories = AppCategories.byType(type);
    final accentColor = type == TransactionType.income ? AppColors.income : AppColors.expense;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: categories.map((cat) {
        final isSelected = selected == cat.name;
        return InkWell(
          onTap: () => onSelect(cat.name),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? accentColor.withOpacity(0.12) : Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? accentColor : Theme.of(context).dividerColor,
                width: isSelected ? 1.6 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(cat.icon, size: 18, color: isSelected ? accentColor : Theme.of(context).iconTheme.color),
                const SizedBox(width: 6),
                Text(
                  cat.name,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? accentColor : null,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
