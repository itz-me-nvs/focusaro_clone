import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialize() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        const InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            ((NotificationResponse notificationResponse) {
      switch (notificationResponse.notificationResponseType) {
        case NotificationResponseType.selectedNotification:
          print('selected notification');
          break;
        case NotificationResponseType.selectedNotificationAction:
          // TODO: Handle this case.
          print('selected notification action');
          break;
      }
    }));
  }

  static Future<void> scheduleNotification(tz.TZDateTime scheduledDate,
      String time, Function() onTimeExceeded) async {
    String channelID = 'time_channel_ID';
    String channelName = 'time_channel_name';
    int notificationID = int.parse(
        time.replaceAll(':', '')); // Use a unique ID for each notification.
    const channelDescription = 'focus mode notification based on time';

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      channelID,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.low,
      showWhen: false,
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationID,
        'Focus Mode Enabled',
        'Time to focus on your work',
        scheduledDate,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);

    // Calculate the delay to perform the action using timer.
    final delay =
        scheduledDate.difference(tz.TZDateTime.now(tz.local)).inMilliseconds;
    Timer(Duration(milliseconds: delay), onTimeExceeded);
  }
}
