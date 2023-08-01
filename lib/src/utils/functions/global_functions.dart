import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sound_mode/permission_handler.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';

TimeOfDay convertTimeOfDay(String timeString) {
  List<String> timeParts = timeString.split(' ');
  List<int> hourMinuteParts = timeParts[0].split(':').map(int.parse).toList();

  int hours = hourMinuteParts[0];
  int minutes = hourMinuteParts[1];

  String Period = timeParts[1];

  // adjust for PM (after noon)
  if (Period == 'PM' && hours != 12) {
    hours = hours + 12;
  }

  return TimeOfDay(hour: hours, minute: minutes);
}

Future<void> setSilentMode() async {
  String message;

  try {
    message = (await SoundMode.setSoundMode(RingerModeStatus.silent)) as String;
  } on PlatformException {
    print('Do Not Disturb access permissions required!');
    openDoNotDisturbSettings();
  }
}

Future<void> setNormalMode() async {
  RingerModeStatus message;

  try {
    message = (await SoundMode.setSoundMode(RingerModeStatus.normal))
        as RingerModeStatus;
  } on PlatformException {
    print('Do Not Disturb access permissions required!');
    openDoNotDisturbSettings();
  }
}

Future<void> setVibrateMode() async {
  String message;
  try {
    message = await SoundMode.setSoundMode(RingerModeStatus.vibrate) as String;
  } on PlatformException {
    print('Do Not Disturb access permissions required!');
    openDoNotDisturbSettings();
  }
}

Future<void> openDoNotDisturbSettings() async {
  await PermissionHandler.openDoNotDisturbSetting();
}
