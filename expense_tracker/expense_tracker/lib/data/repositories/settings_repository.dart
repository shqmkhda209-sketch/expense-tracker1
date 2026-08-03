import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/currency_formatter.dart';

/// ریپازیتوری مسئول ذخیره و بازیابی تنظیمات ساده برنامه
/// (تم، واحد پول، وضعیت یادآوری روزانه) با استفاده از SharedPreferences
class SettingsRepository {
  static const String _keyThemeMode = 'theme_mode'; // light | dark | system
  static const String _keyCurrency = 'currency_type';
  static const String _keyReminderEnabled = 'reminder_enabled';
  static const String _keyReminderHour = 'reminder_hour';
  static const String _keyReminderMinute = 'reminder_minute';

  Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyThemeMode) ?? 'system';
  }

  Future<void> setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode);
  }

  Future<CurrencyType> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_keyCurrency) ?? CurrencyType.toman.name;
    return CurrencyTypeExt.fromName(name);
  }

  Future<void> setCurrency(CurrencyType currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrency, currency.name);
  }

  Future<bool> getReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyReminderEnabled) ?? false;
  }

  Future<void> setReminderEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyReminderEnabled, enabled);
  }

  Future<(int, int)> getReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(_keyReminderHour) ?? 21;
    final minute = prefs.getInt(_keyReminderMinute) ?? 0;
    return (hour, minute);
  }

  Future<void> setReminderTime(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyReminderHour, hour);
    await prefs.setInt(_keyReminderMinute, minute);
  }
}
