import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';

class NotificationService {
  static Future<void> showWeatherNotification(
      String city, String temp, String condition) async {

    const androidDetails = AndroidNotificationDetails(
      'weather_channel',
      'Weather Updates',
      channelDescription: 'Weather update notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await notificationsPlugin.show(
      id: 0,
      title: 'Погода обновлена',
      body: '$city: $temp, $condition',
      notificationDetails:  details,
    );
  }
}
