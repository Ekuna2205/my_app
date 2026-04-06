import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static Future<void> saveSession({
    required String role,
    required String identifier,
    required String displayName,
    required bool rememberMe,
  }) async {
    if (kIsWeb) return; // 👈 WEB дээр алгасна

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loggedIn', true);
    await prefs.setString('role', role);
    await prefs.setString('identifier', identifier);
    await prefs.setString('displayName', displayName);
    await prefs.setBool('rememberMe', rememberMe);
  }

  static Future<Map<String, dynamic>> getSession() async {
    if (kIsWeb) {
      return {
        'loggedIn': false,
        'role': '',
        'identifier': '',
        'displayName': '',
        'rememberMe': false,
      };
    }

    final prefs = await SharedPreferences.getInstance();

    return {
      'loggedIn': prefs.getBool('loggedIn') ?? false,
      'role': prefs.getString('role') ?? '',
      'identifier': prefs.getString('identifier') ?? '',
      'displayName': prefs.getString('displayName') ?? '',
      'rememberMe': prefs.getBool('rememberMe') ?? false,
    };
  }

  static Future<void> clearSession() async {
    if (kIsWeb) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
