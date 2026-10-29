import 'package:shared_preferences/shared_preferences.dart';

class SessionStorage {
  static const _tokenKey = 'api_auth_token';
  static const _emailKey = 'api_auth_email';
  SharedPreferences? _preferences;

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  String? get token => _preferences?.getString(_tokenKey);
  String? get email => _preferences?.getString(_emailKey);

  Future<bool> save({required String token, required String email}) async {
    final preferences = _preferences;
    if (preferences == null) {
      throw StateError('Session storage must be initialized before authentication.');
    }
    if (!await preferences.setString(_tokenKey, token) || !await preferences.setString(_emailKey, email)) {
      await clear();
      return false;
    }
    return true;
  }

  Future<void> clear() async {
    final preferences = _preferences;
    if (preferences == null) return;
    await preferences.remove(_tokenKey);
    await preferences.remove(_emailKey);
  }
}
