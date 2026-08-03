import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// سرویس مسئول تنظیم و لغو اعلان یادآوری روزانه ثبت هزینه‌ها.
/// تمام عملیات کاملاً محلی و بدون نیاز به اینترنت انجام می‌شود.
class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const int _dailyReminderId = 1001;

  Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);

    // درخواست مجوز نمایش اعلان (اندروید ۱۳ به بالا)
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  /// زمان‌بندی یادآوری روزانه در ساعت مشخص‌شده توسط کاربر
  Future<void> scheduleDailyReminder({required int hour, required int minute}) async {
    await init();
    await _plugin.zonedSchedule(
      _dailyReminderId,
      'یادآوری ثبت هزینه',
      'فراموش نکنید هزینه‌های امروز خود را ثبت کنید 📝',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel',
          'یادآوری روزانه',
          channelDescription: 'یادآوری روزانه برای ثبت تراکنش‌های مالی',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDailyReminder() async {
    await _plugin.cancel(_dailyReminderId);
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
