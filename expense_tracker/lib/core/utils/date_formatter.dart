import 'package:shamsi_date/shamsi_date.dart';

/// کلاس کمکی برای نمایش تاریخ میلادی به‌صورت شمسی (جلالی)
class DateFormatter {
  DateFormatter._();

  static const List<String> _weekDays = [
    'شنبه', 'یکشنبه', 'دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنجشنبه', 'جمعه'
  ];

  static const List<String> _monthNames = [
    'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور',
    'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند'
  ];

  /// نمایش کامل تاریخ، مثال: «۱۲ مرداد ۱۴۰۴»
  static String toJalaliString(DateTime date) {
    final jalali = Jalali.fromDateTime(date);
    return '${_toPersianDigits(jalali.day)} ${_monthNames[jalali.month - 1]} ${_toPersianDigits(jalali.year)}';
  }

  /// نمایش کوتاه تاریخ، مثال: «۱۴۰۴/۰۵/۱۲»
  static String toJalaliShort(DateTime date) {
    final jalali = Jalali.fromDateTime(date);
    final m = jalali.month.toString().padLeft(2, '0');
    final d = jalali.day.toString().padLeft(2, '0');
    return _toPersianDigits('${jalali.year}/$m/$d');
  }

  /// نمایش روز هفته و تاریخ، مثال: «سه‌شنبه، ۱۲ مرداد»
  static String toJalaliWithWeekday(DateTime date) {
    final jalali = Jalali.fromDateTime(date);
    final weekday = _weekDays[jalali.weekDay - 1];
    return '$weekday، ${_toPersianDigits(jalali.day)} ${_monthNames[jalali.month - 1]}';
  }

  /// نام ماه شمسی جاری برای یک تاریخ (برای گروه‌بندی گزارش ماهانه)
  static String monthYearKey(DateTime date) {
    final jalali = Jalali.fromDateTime(date);
    return '${jalali.year}-${jalali.month.toString().padLeft(2, '0')}';
  }

  static String monthLabel(int month) => _monthNames[month - 1];

  /// آیا تاریخ داده‌شده در همین ماه شمسی جاری است؟
  static bool isSameJalaliMonth(DateTime date, DateTime reference) {
    final j1 = Jalali.fromDateTime(date);
    final j2 = Jalali.fromDateTime(reference);
    return j1.year == j2.year && j1.month == j2.month;
  }

  static String _toPersianDigits(dynamic input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    String result = input.toString();
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], persian[i]);
    }
    return result;
  }
}
