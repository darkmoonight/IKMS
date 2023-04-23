import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ikms/main.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationShow {
  Future showNotification(
      int id, String title, String body, DateTime? date) async {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails(
      'IKMS',
      'DARK NIGHT',
      priority: Priority.max,
      importance: Importance.max,
    );
    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    var scheduledTime = tz.TZDateTime.from(date!, tz.local);
    flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
      payload: 'notlification-payload',
    );
  }
}
