import 'package:shared_preferences/shared_preferences.dart';

/// The signed-in session remembered between app launches, so the splash
/// screen can send a returning user to [AppLockScreen] instead of back
/// through sign in. Holds no password or token — just enough to greet the
/// user and re-authenticate them (email + display name).
class StoredSession {
  const StoredSession({required this.email, required this.displayName});

  final String email;
  final String displayName;
}

class SessionStore {
  static const _emailKey = 'session_email';
  static const _displayNameKey = 'session_display_name';

  Future<void> save({
    required String email,
    required String displayName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
    await prefs.setString(_displayNameKey, displayName);
  }

  Future<StoredSession?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_emailKey);
    final displayName = prefs.getString(_displayNameKey);
    if (email == null || displayName == null) return null;
    return StoredSession(email: email, displayName: displayName);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_emailKey);
    await prefs.remove(_displayNameKey);
  }
}
