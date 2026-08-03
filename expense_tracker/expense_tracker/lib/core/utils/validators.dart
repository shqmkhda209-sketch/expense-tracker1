import '../constants/app_strings.dart';
import 'currency_formatter.dart';

/// توابع کمکی برای اعتبارسنجی فیلدهای فرم
class Validators {
  Validators._();

  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.amountRequired;
    }
    final parsed = CurrencyFormatter.parse(value);
    if (parsed == null || parsed <= 0) {
      return AppStrings.amountInvalid;
    }
    return null;
  }

  static String? title(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.titleRequired;
    }
    return null;
  }

  static String? category(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.categoryRequired;
    }
    return null;
  }
}
