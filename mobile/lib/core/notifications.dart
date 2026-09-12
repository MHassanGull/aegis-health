import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;

/// Thin wrapper over flutter_local_notifications for repeating health reminders.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _inited = false;

  Future<void> init() async {
    if (_inited) return;
    tzdata.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
    _inited = true;
  }

  /// Ask for the Android 13+ notification permission (and exact-alarm
  /// permission so reminders fire on time). Returns whether notifications
  /// are granted.
  Future<bool> requestPermission() async {
    await init();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    try {
      await android?.requestExactAlarmsPermission();
    } catch (_) {/* older Android / not required */}
    return granted ?? true;
  }

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          'aegis_reminders',
          'Health Reminders',
          channelDescription: 'Gentle reminders to keep you healthy',
          importance: Importance.high,
          priority: Priority.high,
        ),
      );

  /// Schedule a repeating reminder every [every] (inexact — battery-friendly,
  /// no exact-alarm permission needed).
  Future<void> scheduleInterval({
    required int id,
    required String title,
    required String body,
    required Duration every,
  }) async {
    await init();
    await _plugin.periodicallyShowWithDuration(
      id,
      title,
      body,
      every,
      _details,
      // Exact alarm that also fires in Doze — reliable reminder timing.
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id);

  /// Fire a notification immediately (used by the "Test" button for demos).
  Future<void> showNow(int id, String title, String body) async {
    await init();
    await _plugin.show(id, title, body, _details);
  }
}
