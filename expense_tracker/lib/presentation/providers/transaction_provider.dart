import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_categories.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';

enum TransactionFilter { all, incomeOnly, expenseOnly }
enum TransactionSort { newest, oldest, highestAmount, lowestAmount }

/// پرووایدر اصلی برنامه: مسئول نگهداری لیست تراکنش‌ها در حافظه،
/// اعمال جستجو/فیلتر/مرتب‌سازی و محاسبه آمار برای صفحه اصلی و گزارش‌ها.
class TransactionProvider extends ChangeNotifier {
  final TransactionRepository _repository;
  final _uuid = const Uuid();

  TransactionProvider({required TransactionRepository repository}) : _repository = repository;

  List<TransactionEntity> _all = [];
  bool _loading = true;
  String? _error;

  // وضعیت جستجو/فیلتر/مرتب‌سازی
  String _searchQuery = '';
  TransactionFilter _filter = TransactionFilter.all;
  TransactionSort _sort = TransactionSort.newest;
  DateTimeRange? _dateRange;
  String? _categoryFilter;

  bool get loading => _loading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  TransactionFilter get filter => _filter;
  TransactionSort get sort => _sort;
  DateTimeRange? get dateRange => _dateRange;
  String? get categoryFilter => _categoryFilter;

  List<TransactionEntity> get all => List.unmodifiable(_all);

  /// بارگذاری اولیه تراکنش‌ها از پایگاه داده
  Future<void> loadTransactions() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _all = await _repository.getAll();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ---------------------- عملیات CRUD ----------------------

  Future<void> addTransaction({
    required double amount,
    required String title,
    required String category,
    required TransactionType type,
    required DateTime date,
    String? description,
  }) async {
    final entity = TransactionEntity(
      id: _uuid.v4(),
      amount: amount,
      title: title.trim(),
      category: category,
      type: type,
      date: date,
      description: (description == null || description.trim().isEmpty) ? null : description.trim(),
      createdAt: DateTime.now(),
    );
    await _repository.add(entity);
    _all.insert(0, entity);
    _sortLocal();
    notifyListeners();
  }

  Future<void> updateTransaction(TransactionEntity updated) async {
    await _repository.update(updated);
    final index = _all.indexWhere((t) => t.id == updated.id);
    if (index != -1) {
      _all[index] = updated;
    }
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    await _repository.delete(id);
    _all.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  Future<void> deleteAllTransactions() async {
    await _repository.deleteAll();
    _all.clear();
    notifyListeners();
  }

  /// جایگزینی کامل داده‌ها هنگام بازیابی نسخه پشتیبان
  Future<void> restoreFromBackup(List<TransactionEntity> transactions) async {
    await _repository.deleteAll();
    await _repository.insertBatch(transactions);
    _all = await _repository.getAll();
    notifyListeners();
  }

  // ---------------------- جستجو / فیلتر / مرتب‌سازی ----------------------

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter(TransactionFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  void setSort(TransactionSort sort) {
    _sort = sort;
    notifyListeners();
  }

  void setDateRange(DateTimeRange? range) {
    _dateRange = range;
    notifyListeners();
  }

  void setCategoryFilter(String? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void clearFilters() {
    _filter = TransactionFilter.all;
    _dateRange = null;
    _categoryFilter = null;
    _searchQuery = '';
    notifyListeners();
  }

  void _sortLocal() {
    _all = _applySort(_all, _sort);
  }

  List<TransactionEntity> _applySort(List<TransactionEntity> list, TransactionSort sort) {
    final copy = [...list];
    switch (sort) {
      case TransactionSort.newest:
        copy.sort((a, b) => b.date.compareTo(a.date));
        break;
      case TransactionSort.oldest:
        copy.sort((a, b) => a.date.compareTo(b.date));
        break;
      case TransactionSort.highestAmount:
        copy.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case TransactionSort.lowestAmount:
        copy.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }
    return copy;
  }

  /// خروجی نهایی لیست فیلتر/جستجو/مرتب‌سازی‌شده برای نمایش در UI
  List<TransactionEntity> get filteredTransactions {
    Iterable<TransactionEntity> result = _all;

    if (_filter == TransactionFilter.incomeOnly) {
      result = result.where((t) => t.isIncome);
    } else if (_filter == TransactionFilter.expenseOnly) {
      result = result.where((t) => t.isExpense);
    }

    if (_categoryFilter != null) {
      result = result.where((t) => t.category == _categoryFilter);
    }

    if (_dateRange != null) {
      result = result.where((t) =>
          !t.date.isBefore(_dateRange!.start) &&
          !t.date.isAfter(_dateRange!.end.add(const Duration(days: 1))));
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      result = result.where((t) =>
          t.title.toLowerCase().contains(q) ||
          t.category.toLowerCase().contains(q) ||
          (t.description?.toLowerCase().contains(q) ?? false));
    }

    return _applySort(result.toList(), _sort);
  }

  // ---------------------- آمار صفحه اصلی ----------------------

  double get totalIncome => _all.where((t) => t.isIncome).fold(0.0, (sum, t) => sum + t.amount);
  double get totalExpense => _all.where((t) => t.isExpense).fold(0.0, (sum, t) => sum + t.amount);
  double get totalBalance => totalIncome - totalExpense;

  List<TransactionEntity> get recentTransactions {
    final sorted = _applySort(_all, TransactionSort.newest);
    return sorted.take(5).toList();
  }

  // ---------------------- آمار گزارش‌ها (ماه جاری شمسی) ----------------------

  List<TransactionEntity> get _currentMonthTransactions {
    final now = DateTime.now();
    return _all.where((t) => DateFormatter.isSameJalaliMonth(t.date, now)).toList();
  }

  double get monthlyIncome =>
      _currentMonthTransactions.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount);

  double get monthlyExpense =>
      _currentMonthTransactions.where((t) => t.isExpense).fold(0.0, (s, t) => s + t.amount);

  double get monthlyBalance => monthlyIncome - monthlyExpense;

  /// جمع هزینه به تفکیک دسته‌بندی (برای نمودار دایره‌ای)
  Map<String, double> get expenseByCategory {
    final Map<String, double> map = {};
    for (final t in _all.where((t) => t.isExpense)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  /// جمع درآمد به تفکیک دسته‌بندی
  Map<String, double> get incomeByCategory {
    final Map<String, double> map = {};
    for (final t in _all.where((t) => t.isIncome)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  String? get topExpenseCategory {
    final map = expenseByCategory;
    if (map.isEmpty) return null;
    return map.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  String? get topIncomeCategory {
    final map = incomeByCategory;
    if (map.isEmpty) return null;
    return map.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  /// داده ۶ ماه اخیر برای نمودار میله‌ای درآمد/هزینه ماهانه
  /// خروجی: لیستی از (برچسب ماه, مجموع درآمد, مجموع هزینه)
  List<(String, double, double)> get monthlyChartData {
    final now = DateTime.now();
    final buckets = <String, (double, double)>{};
    final labels = <String, String>{};

    for (int i = 5; i >= 0; i--) {
      final refDate = DateTime(now.year, now.month - i, 1);
      final key = DateFormatter.monthYearKey(refDate);
      buckets[key] = (0, 0);
    }

    for (final t in _all) {
      final key = DateFormatter.monthYearKey(t.date);
      if (!buckets.containsKey(key)) continue;
      final current = buckets[key]!;
      if (t.isIncome) {
        buckets[key] = (current.$1 + t.amount, current.$2);
      } else {
        buckets[key] = (current.$1, current.$2 + t.amount);
      }
    }

    return buckets.entries.map((e) {
      final month = int.parse(e.key.split('-')[1]);
      return (DateFormatter.monthLabel(month), e.value.$1, e.value.$2);
    }).toList();
  }

  List<String> get allCategories {
    final set = <String>{};
    for (final t in _all) {
      set.add(t.category);
    }
    return set.toList();
  }
}
