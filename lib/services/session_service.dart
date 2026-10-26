import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _userIdKey = 'logged_in_user_id';

  static Future<void> saveUserId(int userId) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_userIdKey, userId);
  }

  static Future<int?> getUserId() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getInt(_userIdKey);
  }

  static Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_userIdKey);
  }
}
