import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const _keyId = 'current_user_id';
  static const _keyEmail = 'current_user_email';

  static Future<void> saveSession(String userId, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyId, userId);
    await prefs.setString(_keyEmail, email);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyId);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Xóa sạch để bảo mật
  }
}