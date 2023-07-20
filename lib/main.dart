import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:focusaro_clone/src/app.dart';
import 'package:focusaro_clone/src/utils/services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
/* Initialize Firebase */
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  NotificationService.initialize();

  // timezone initialization
  tz.initializeTimeZones();

  final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();

  // Set the local time zone
  tz.setLocalLocation(tz.getLocation(timeZoneName));

  runApp(App());
}
