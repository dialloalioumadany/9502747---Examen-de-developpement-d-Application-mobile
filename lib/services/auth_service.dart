import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _emailKey = 'user_email';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _lastLoginKey = 'last_login';
  
  static const String _validEmail = 'dialloalioumadany@gmail.com';
  static const String _validPassword = '4glog123';

  static const Duration _sessionDuration = Duration(hours: 24);

  static Future<bool> login(String email, String password) async {
    if (email == _validEmail && password == _validPassword) {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;
      
      await prefs.setString(_emailKey, email);
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setInt(_lastLoginKey, now);
      
      return true;
    }
    return false;
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    
    if (!isLoggedIn) return false;

    final lastLogin = prefs.getInt(_lastLoginKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final sessionValid = (now - lastLogin) < _sessionDuration.inMilliseconds;

    if (!sessionValid) {
      await logout();
      return false;
    }

    await prefs.setInt(_lastLoginKey, now);
    return true;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_emailKey);
    await prefs.remove(_lastLoginKey);
    await prefs.setBool(_isLoggedInKey, false);
  }
} 