import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ikms/main.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationShow {
  final String _channelId = 'IKMS';
  final String _channelName = 'DARK NIGHT';
  final String _payload = 'notification-payload';

  Future<void> showNotification(
    int id,
    String title,
    String body,
    DateTime? date,
  ) async {
    await _requestNotificationPermission();
    final notificationDetails = _buildNotificationDetails();
    final scheduledTime = _getScheduledTime(date!);

    await flutterLocalNotificationsPlugin.zonedSchedule(
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
    final platform = flutterLocalNotificationsPlugin
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
