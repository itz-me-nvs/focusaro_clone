import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:focusaro_clone/src/app.dart';

void main() async {
/* Initialize Firebase */
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(App());
}
