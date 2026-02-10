import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';

class NotificationService {
  static Future<void> showSimpleNotification(
      String title, String body) async {

    final androidDetails = AndroidNotificationDetails(
      'weather_channel',
      'Weather Notifications',
      channelDescription: 'Weather alerts',
      importance: Importance.max,
      priority: Priority.high,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await notificationsPlugin.show(
      id: 1,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
    );
  }
}