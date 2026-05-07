import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/reminder_model.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  // ─── INITIALIZE ────────────────  ───────────────────────

  static Future<void> init() async {
    if (_initialized) return;

    // Timezone setup
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Karachi'));

    // Android settings
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const iOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: android,
      iOS: iOS,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
    debugPrint('✅ Notification Service Initialized');
  }

  // ─── REQUEST PERMISSIONS ──────────────────────────────

  static Future<bool> requestPermissions() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      debugPrint('🔔 Android Permission: $granted');
      return granted ?? false;
    }

    final iOS = _plugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (iOS != null) {
      final granted = await iOS.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('🔔 iOS Permission: $granted');
      return granted ?? false;
    }

    return false;
  }

  // ─── SCHEDULE REMINDER ────────────────────────────────

  static Future<void> scheduleReminder(ReminderModel reminder) async {
    if (!_initialized) await init();

    const androidDetails = AndroidNotificationDetails(
      'dailypulse_channel',
      'DailyPulse Reminders',
      channelDescription: 'Daily habit reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule time calculate karo
    final now = DateTime.now();
    var scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      reminder.time.hour,
      reminder.time.minute,
    );

    // Agar time nikal gaya aaj ka, toh kal schedule karo
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await _plugin.zonedSchedule(
      reminder.id.hashCode, // unique ID
      'DailyPulse ⚡',
      '${reminder.title} ka time ho gaya!',
      tzScheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // daily repeat
    );

    debugPrint('🔔 Scheduled: ${reminder.title} at $scheduledTime');
  }

  // ─── CANCEL REMINDER ──────────────────────────────────

  static Future<void> cancelReminder(String id) async {
    await _plugin.cancel(id.hashCode);
    debugPrint('❌ Cancelled: $id');
  }

  // ─── CANCEL ALL ───────────────────────────────────────

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
    debugPrint('❌ All notifications cancelled');
  }

  // ─── INSTANT NOTIFICATION (testing) ───────────────────

  static Future<void> showInstantNotification(
      String title,
      String body,
      ) async {
    if (!_initialized) await init();

    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
    );
  }

  // ─── NOTIFICATION TAP HANDLER ─────────────────────────

  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Notification tapped: ${response.payload}');
  }

  // ─── GET PENDING NOTIFICATIONS ────────────────────────

  static Future<int> getPendingCount() async {
    final pending = await _plugin.pendingNotificationRequests();
    return pending.length;
  }
}
