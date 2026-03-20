import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const _key = 'current_user_id';

  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, userId);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }
}
