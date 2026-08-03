import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_categories.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/validators.dart';
import '../../domain/entities/transaction_entity.dart';
import '../providers/transaction_provider.dart';
import '../widgets/category_picker.dart';
import '../widgets/custom_text_field.dart';

/// صفحه افزودن تراکنش جدید یا ویرایش تراکنش موجود.
/// اگر [editingTransaction] مقدار داشته باشد، فرم در حالت ویرایش نمایش داده می‌شود.
class AddTransactionScreen extends StatefulWidget {
  final TransactionType type;
  final TransactionEntity? editingTransaction;

  const AddTransactionScreen({super.key, required this.type, this.editingTransaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  String? _selectedCategory;
  late DateTime _selectedDate;
  bool _saving = false;

  bool get _isEditing => widget.editingTransaction != null;

  @override
  void initState() {
    super.initState();
    final editing = widget.editingTransaction;
    _amountController = TextEditingController(
      text: editing != null ? CurrencyFormatter.formatNumber(editing.amount) : '',
    );
    _titleController = TextEditingController(text: editing?.title ?? '');
    _descriptionController = TextEditingController(text: editing?.description ?? '');
    _selectedCategory = editing?.category;
    _selectedDate = editing?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _isIncome => widget.type == TransactionType.income;
  Color get _accentColor => _isIncome ? AppColors.income : AppColors.expense;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2015),
      lastDate: DateTime(2035),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: _accentColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.categoryRequired)),
      );
      return;
    }

    setState(() => _saving = true);
    final provider = context.read<TransactionProvider>();
    final amount = CurrencyFormatter.parse(_amountController.text) ?? 0;

    try {
      if (_isEditing) {
        final updated = widget.editingTransaction!.copyWith(
          amount: amount,
          title: _titleController.text.trim(),
          category: _selectedCategory,
          date: _selectedDate,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        );
        await provider.updateTransaction(updated);
      } else {
        await provider.addTransaction(
          amount: amount,
          title: _titleController.text.trim(),
          category: _selectedCategory!,
          type: widget.type,
          date: _selectedDate,
          description: _descriptionController.text.trim(),
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? AppStrings.updatedSuccessfully : AppStrings.savedSuccessfully),
          backgroundColor: _accentColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditing
        ? AppStrings.editTransaction
        : (_isIncome ? AppStrings.newIncome : AppStrings.newExpense);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            CustomTextField(
              label: AppStrings.amount,
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: Validators.amount,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
              prefixIcon: Icon(Icons.payments_outlined, color: _accentColor),
            ),
            const SizedBox(height: 18),
            CustomTextField(
              label: AppStrings.title,
              controller: _titleController,
              validator: Validators.title,
              prefixIcon: const Icon(Icons.edit_outlined),
            ),
            const SizedBox(height: 18),
            Text(AppStrings.category, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            CategoryPicker(
              type: widget.type,
              selected: _selectedCategory,
              onSelect: (cat) => setState(() => _selectedCategory = cat),
            ),
            const SizedBox(height: 18),
            CustomTextField(
              label: AppStrings.date,
              controller: TextEditingController(text: DateFormatter.toJalaliString(_selectedDate)),
              readOnly: true,
              onTap: _pickDate,
              prefixIcon: const Icon(Icons.calendar_today_outlined),
            ),
            const SizedBox(height: 18),
            CustomTextField(
              label: AppStrings.description,
              controller: _descriptionController,
              maxLines: 3,
              prefixIcon: const Icon(Icons.notes_outlined),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: _accentColor),
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(_isEditing ? AppStrings.update : AppStrings.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
