import 'package:shared_preferences/shared_preferences.dart';

/// 마지막으로 로그인한 계정의 로그인 아이디를 기기에 저장하고 읽는 저장소다.
abstract interface class SessionStore {
  Future<String?> readLoginId();

  Future<void> saveLoginId(String loginId);

  Future<void> clearLoginId();
}

class SharedPrefsSessionStore implements SessionStore {
  static const _loginIdKey = 'active_login_id';

  @override
  Future<void> clearLoginId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loginIdKey);
  }

  @override
  Future<String?> readLoginId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_loginIdKey);
  }

  @override
  Future<void> saveLoginId(String loginId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_loginIdKey, loginId);
  }
}
