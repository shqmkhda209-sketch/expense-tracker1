import '../../core/constants/app_categories.dart';

/// موجودیت تراکنش؛ نمایانگر یک رکورد درآمد یا هزینه در سطح منطق کسب‌وکار
/// (مستقل از جزئیات پایگاه داده)
class TransactionEntity {
  final String id;
  final double amount;
  final String title;
  final String category;
  final TransactionType type;
  final DateTime date;
  final String? description;
  final DateTime createdAt;

  const TransactionEntity({
    required this.id,
    required this.amount,
    required this.title,
    required this.category,
    required this.type,
    required this.date,
    this.description,
    required this.createdAt,
  });

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;

  /// مبلغ با علامت (مثبت برای درآمد، منفی برای هزینه) — برای محاسبه موجودی
  double get signedAmount => isIncome ? amount : -amount;

  TransactionEntity copyWith({
    String? id,
    double? amount,
    String? title,
    String? category,
    TransactionType? type,
    DateTime? date,
    String? description,
    DateTime? createdAt,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      title: title ?? this.title,
      category: category ?? this.category,
      type: type ?? this.type,
      date: date ?? this.date,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
