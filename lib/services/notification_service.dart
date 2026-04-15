import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static const String _channelId = 'aquanimity_alerts';
  static const String _channelName = 'Aquanimity Alerts';
  static const String _channelDescription = 'Dive, streak, and treasure notifications for Aquanimity.';
  static const int streakReminderId = 100;

  bool get _isSupportedPlatform {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;
  }

  Future<void> init() async {
    if (!_isSupportedPlatform) {
      return;
    }

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.local);

    final androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _plugin.initialize(initSettings);
    await _requestPermissions();
  }

  Future<bool> _requestPermissions() async {
    if (!_isSupportedPlatform) return false;

    if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
      final granted = await _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
        alert: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  NotificationDetails _buildDetails({Color? color}) {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      color: color,
      playSound: true,
      ticker: 'Aquanimity',
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  Future<void> showNotification(int id, String title, String body, {Color? color}) async {
    if (!_isSupportedPlatform) return;
    await _plugin.show(id, title, body, _buildDetails(color: color));
  }

  Future<void> scheduleNotification(int id, String title, String body, DateTime scheduledTime, {Color? color}) async {
    if (!_isSupportedPlatform) return;
    if (scheduledTime.isBefore(DateTime.now())) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(scheduledTime, tz.local);

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        _buildDetails(color: color),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      // Fallback to inexact scheduling if exact fails
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        _buildDetails(color: color),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexact,
      );
    }
  }

  Future<void> cancelNotification(int id) async {
    if (!_isSupportedPlatform) return;
    await _plugin.cancel(id);
  }

  Future<void> scheduleStreakReminder(DateTime scheduledTime) async {
    await cancelNotification(streakReminderId);
    await scheduleNotification(
      streakReminderId,
      'Streak at risk',
      'Complete a dive before midnight to keep your streak alive.',
      scheduledTime,
      color: const Color(0xFF42A5F5),
    );
  }

  Future<void> cancelStreakReminder() async {
    await cancelNotification(streakReminderId);
  }
}
