import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/standalone.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialize() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> scheduleNotification(
      int hour, int minute, Function() onTimeExceeded) async {
    // String channelID = 'time_channel_ID';
    // String channelName = 'time_channel_name';
    // int NotificationID = 1;

    // final now = tz.TZDateTime.now(tz.local);
    // // print(now);
    // // final scheduledDate =
    // //     tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    // var scheduledDate =
    //     tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    // print('called the notification');

    // if (now.isAfter(scheduledDate)) {
    //   // If the scheduled time has already passed, schedule for the next day
    //   print('time passed $scheduledDate $now');
    //   scheduledDate = now.add(const Duration(days: 1));
    // }

    // final AndroidNotificationDetails androidPlatformChannelSpecifics =
    //     // ignore: prefer_const_constructors
    //     AndroidNotificationDetails(
    //   channelID,
    //   channelName,
    //   channelDescription: 'focus mode notification based on time',
    //   importance: Importance.defaultImportance,
    //   priority: Priority.low,
    //   showWhen: false, // Don't show the timestamp
    // );

    // final NotificationDetails platformChannelSpecifics =
    //     NotificationDetails(android: androidPlatformChannelSpecifics);

    // await flutterLocalNotificationsPlugin.zonedSchedule(
    //   NotificationID,
    //   'Scheduled Action',
    //   'Perform your action here',
    //   scheduledDate,
    //   platformChannelSpecifics,
    //   uiLocalNotificationDateInterpretation:
    //       UILocalNotificationDateInterpretation.absoluteTime,
    //   payload: 'scheduled_action', // Add a payload for identification
    // );

    // // Calculate the delay to perform the action
    // final delay = scheduledDate.difference(now);
    // print('delay: $delay');
    // Timer(delay, onTimeExceeded);
    // // onTimeExceeded();

    String channelID = 'time_channel_ID';
    String channelName = 'time_channel_name';
    int NotificationID = 1;
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

    final now = tz.TZDateTime.now(tz.local);
    // final TZDateTime scheduledDate = now.add(Duration(seconds: 5));

    print('calling the notification');

    await flutterLocalNotificationsPlugin.zonedSchedule(
        NotificationID,
        'Scheduled Action',
        'Perform your action here',
        now,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }
}
