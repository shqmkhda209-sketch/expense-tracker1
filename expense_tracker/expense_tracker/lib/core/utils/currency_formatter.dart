import 'package:intl/intl.dart';

/// واحدهای پولی پشتیبانی‌شده در برنامه
enum CurrencyType { toman, rial, dollar, euro }

extension CurrencyTypeExt on CurrencyType {
  String get label {
    switch (this) {
      case CurrencyType.toman:
        return 'تومان';
      case CurrencyType.rial:
        return 'ریال';
      case CurrencyType.dollar:
        return 'دلار';
      case CurrencyType.euro:
        return 'یورو';
    }
  }

  String get symbol {
    switch (this) {
      case CurrencyType.toman:
        return 'تومان';
      case CurrencyType.rial:
        return 'ریال';
      case CurrencyType.dollar:
        return '\$';
      case CurrencyType.euro:
        return '€';
    }
  }

  static CurrencyType fromName(String name) {
    return CurrencyType.values.firstWhere(
      (e) => e.name == name,
      orElse: () => CurrencyType.toman,
    );
  }
}

/// کلاس کمکی برای فرمت کردن اعداد مالی به‌صورت خوانا
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _numberFormat = NumberFormat('#,###');

  /// فرمت کردن یک مبلغ به همراه واحد پول، مثال: «۱۲۵,۰۰۰ تومان»
  static String format(double amount, CurrencyType currency) {
    final formattedNumber = _numberFormat.format(amount.round());
    if (currency == CurrencyType.dollar || currency == CurrencyType.euro) {
      return '${currency.symbol}${_numberFormat.format(amount)}';
    }
    return '$formattedNumber ${currency.symbol}';
  }

  /// فرمت کردن عدد بدون واحد پول (برای فیلدهای ورودی)
  static String formatNumber(double amount) {
    return _numberFormat.format(amount);
  }

  /// تبدیل رشته ورودی کاربر (شامل کاما) به عدد اعشاری
  static double? parse(String input) {
    final cleaned = input.replaceAll(',', '').replaceAll('٬', '').trim();
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }
}
