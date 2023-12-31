// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:focusaro_clone/src/screens/home/chat_screen.dart';
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
  // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  //     FlutterLocalNotificationsPlugin();
  App() {}

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
              'chat_screen': (context) => const ChatScreen(),
              'location_screen': (context) => const LocationScreen(),
              'settings_screen': (context) => const SettingsScreen(),
            },

            // onGenerateRoute: (settings) {
            //   switch (settings.name) {
            //     case '/':
            //       return MaterialPageRoute(
            //           builder: (_) => const WelcomeScreen());
            //     case 'phone_auth_screen':
            //       return MaterialPageRoute(
            //           builder: (_) => const PhoneAuthScreen());
            //     case 'login_screen':
            //       return MaterialPageRoute(builder: (_) => const LoginScreen());
            //     case 'home_screen':
            //       // final arguments = settings.arguments as Map<String, String>;
            //       return MaterialPageRoute(builder: (_) => MessageListScreen());
            //     case 'chat_screen':
            //       return MaterialPageRoute(builder: (_) => const ChatScreen());
            //     case 'location_screen':
            //       return MaterialPageRoute(
            //           builder: (_) => const LocationScreen());
            //     case 'settings_screen':
            //       return MaterialPageRoute(builder: (_) => SettingsScreen());
            //     default:
            //       return null;
            //   }
            // },
          );
        }));
  }
}
