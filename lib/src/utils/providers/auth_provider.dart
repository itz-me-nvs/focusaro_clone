import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String phoneNumber;
  final String userID;

  User({
    required this.phoneNumber,
    required this.userID,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      phoneNumber: json['phoneNumber'],
      userID: json['userID'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'phoneNumber': phoneNumber, 'userID': userID};
  }
}

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isDarkMode = false;
  User? _user;

  bool get isLoggedIn => _isLoggedIn;
  bool get isDarkMode => _isDarkMode;
  User? get user => _user;

  Future<void> checkLoggedInStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;

    String? userJson = prefs.getString('user');
    _user = userJson != null ? User.fromJson(json.decode(userJson)) : null;

    notifyListeners();
  }

  Future<void> login(String phoneNumber, String userID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setBool('isDarkMode', false);
    User user = User(phoneNumber: phoneNumber, userID: userID);
    String userJson = json.encode(user.toJson());
    await prefs.setString('user', userJson);

    _user = user;
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('user');
    _isLoggedIn = false;
    _user = null;
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = !_isDarkMode;
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }
}
