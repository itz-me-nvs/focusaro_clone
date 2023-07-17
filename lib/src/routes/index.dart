import 'package:flutter/material.dart';
import 'package:focusaro_clone/src/screens/home/settings_screen.dart';
import 'package:focusaro_clone/src/screens/onboarding/login_screen.dart';
import 'package:focusaro_clone/src/screens/onboarding/phone_auth_screen.dart';
import 'package:focusaro_clone/src/screens/onboarding/welcome_screen.dart';
import 'package:focusaro_clone/src/screens/sample.dart';

Route routes(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => const WelcomeScreen());
    case 'phone_auth_screen':
      return MaterialPageRoute(builder: (_) => const PhoneAuthScreen());
    case 'login_screen':
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    case 'chat_screen':
      return MaterialPageRoute(builder: (_) => const WelcomeScreen());
    case 'settings_screen':
      return MaterialPageRoute(builder: (_) => SettingsScreen());
    default:
      return MaterialPageRoute(builder: (_) => const SampleScreen());
  }
}
