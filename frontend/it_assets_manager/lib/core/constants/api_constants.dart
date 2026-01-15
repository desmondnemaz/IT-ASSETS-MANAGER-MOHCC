import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  // Automatically use 10.0.2.2 for Android Emulator, 127.0.0.1 for others.
  // NOTE: If using a PHYSICAL PHONE, replace '127.0.0.1' or '10.0.2.2'
  // with your computer's local IP address (e.g., '192.168.1.5').
  static String get baseUrl {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api/';
    }
    return 'http://127.0.0.1:8000/api/';
  }

  // Auth
  static const String login = 'accounts/login/';
  static const String register = 'accounts/register/';
  static const String updateProfile = 'profiles/update/';
  static const String updateAccount = 'accounts/me/update/';
  static const String finishProfile = 'profiles/finish/';
  static const String profileMe = 'profiles/me/';

  // Locations
  static const String provinces = 'locations/provinces/';
  static const String districts = 'locations/districts/';
  static const String stations = 'locations/stations/';

  // Admin
  static const String adminUserList = 'accounts/admin/users/';
  static String adminResetPassword(int userId) =>
      'accounts/admin/users/$userId/reset-password/';
}
