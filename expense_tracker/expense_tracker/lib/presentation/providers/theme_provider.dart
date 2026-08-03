import 'package:flutter/material.dart';
import '../../data/repositories/settings_repository.dart';

/// مدیریت وضعیت تم برنامه (روشن / تیره / پیش‌فرض سیستم)
class ThemeProvider extends ChangeNotifier {
  final SettingsRepository _settingsRepository;

  ThemeProvider({SettingsRepository? settingsRepository})
      : _settingsRepository = settingsRepository ?? SettingsRepository();

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  /// بارگذاری تم ذخیره‌شده هنگام شروع برنامه
  Future<void> loadTheme() async {
    final mode = await _settingsRepository.getThemeMode();
    _themeMode = _fromString(mode);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _settingsRepository.setThemeMode(_toString(mode));
  }

  ThemeMode _fromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _toString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
