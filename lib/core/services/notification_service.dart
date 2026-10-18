import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// Schedules local notifications for tasks.
class NotificationShow {
  NotificationShow(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  final String _channelId = 'IKMS';
  final String _channelName = 'DARK NIGHT';
  final String _payload = 'notification-payload';

  /// Schedules a notification at [date] for the given task fields.
  Future<void> showNotification(
    int id,
    String title,
    String body,
    DateTime date,
  ) async {
    await _requestNotificationPermission();
    final notificationDetails = _buildNotificationDetails();
    final scheduledTime = _getScheduledTime(date);

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledTime,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: _payload,
    );
  }

  Future<void> _requestNotificationPermission() async {
    final platform = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (platform != null) {
      await platform.requestExactAlarmsPermission();
      await platform.requestNotificationsPermission();
    }
  }

  NotificationDetails _buildNotificationDetails() {
    final androidNotificationDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      priority: Priority.high,
      importance: Importance.max,
    );
    return NotificationDetails(android: androidNotificationDetails);
  }

  tz.TZDateTime _getScheduledTime(DateTime date) =>
      tz.TZDateTime.from(date, tz.local);
}
