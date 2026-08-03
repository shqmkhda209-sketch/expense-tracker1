import 'package:flutter/material.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/repositories/settings_repository.dart';
import '../../services/notification_service.dart';

/// مدیریت وضعیت تنظیمات عمومی: واحد پول و یادآوری روزانه
class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _settingsRepository;
  final NotificationService _notificationService;

  SettingsProvider({
    SettingsRepository? settingsRepository,
    NotificationService? notificationService,
  })  : _settingsRepository = settingsRepository ?? SettingsRepository(),
        _notificationService = notificationService ?? NotificationService.instance;

  CurrencyType _currency = CurrencyType.toman;
  CurrencyType get currency => _currency;

  bool _reminderEnabled = false;
  bool get reminderEnabled => _reminderEnabled;

  TimeOfDay _reminderTime = const TimeOfDay(hour: 21, minute: 0);
  TimeOfDay get reminderTime => _reminderTime;

  bool _loading = true;
  bool get loading => _loading;

  Future<void> loadSettings() async {
    _currency = await _settingsRepository.getCurrency();
    _reminderEnabled = await _settingsRepository.getReminderEnabled();
    final (h, m) = await _settingsRepository.getReminderTime();
    _reminderTime = TimeOfDay(hour: h, minute: m);
    _loading = false;
    notifyListeners();
  }

  Future<void> setCurrency(CurrencyType currency) async {
    _currency = currency;
    notifyListeners();
    await _settingsRepository.setCurrency(currency);
  }

  Future<void> setReminderEnabled(bool enabled) async {
    _reminderEnabled = enabled;
    notifyListeners();
    await _settingsRepository.setReminderEnabled(enabled);
    if (enabled) {
      await _notificationService.scheduleDailyReminder(
        hour: _reminderTime.hour,
        minute: _reminderTime.minute,
      );
    } else {
      await _notificationService.cancelDailyReminder();
    }
  }

  Future<void> setReminderTime(TimeOfDay time) async {
    _reminderTime = time;
    notifyListeners();
    await _settingsRepository.setReminderTime(time.hour, time.minute);
    if (_reminderEnabled) {
      await _notificationService.scheduleDailyReminder(
        hour: time.hour,
        minute: time.minute,
      );
    }
  }
}
