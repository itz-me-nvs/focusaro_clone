import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:focusaro_clone/src/screens/home/location_screen.dart';
import 'package:focusaro_clone/src/screens/home/message_list_screen.dart';
import 'package:focusaro_clone/src/screens/home/settings_screen.dart';
import 'package:focusaro_clone/src/screens/onboarding/login_screen.dart';
import 'package:focusaro_clone/src/screens/onboarding/phone_auth_screen.dart';
import 'package:focusaro_clone/src/screens/onboarding/welcome_screen.dart';
import 'package:focusaro_clone/src/utils/providers/auth_provider.dart';
import 'package:provider/provider.dart';

import 'config/theme_data.dart';

class App extends StatelessWidget {
  /* Flutter Local Notifications */
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Map data = {'name': 'Sammy Shark', 'email': 'example@example.com', 'age': 42};
  App() {
    final initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthProvider>(
        create: (context) => AuthProvider(),
        child: Consumer<AuthProvider>(builder: (context, appState, _) {
          // Check the logged-in status
          appState.checkLoggedInStatus();
          return MaterialApp(
            title: 'News!',
            theme: ThemeConfig.lightTheme,
            darkTheme: ThemeConfig.darkTheme,
            themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            initialRoute: '/',
            routes: {
              '/': (context) => const WelcomeScreen(),
              'phone_auth_screen': (context) => const PhoneAuthScreen(),
              'login_screen': (context) => const LoginScreen(),
              'home_screen': (context) => const MessageListScreen(),
              'chat_screen': (context) => const WelcomeScreen(),
              'location_screen': (context) => const LocationScreen(),
              'settings_screen': (context) => SettingsScreen(),
            },
          );
        }));
  }
}
