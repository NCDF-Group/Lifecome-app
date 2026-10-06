import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The signed-in session remembered between app launches, so the splash screen can send a
/// returning user to [AppLockScreen] instead of back through sign in. The email and display name
/// are enough to greet the user; the access token (kept in the platform's secure storage, never in
/// plain preferences) lets the app talk to the backend again after a biometric unlock without
/// asking for the password.
class StoredSession {
  const StoredSession({
    required this.email,
    required this.displayName,
    this.accessToken,
  });

  final String email;
  final String displayName;
  final String? accessToken;
}

class SessionStore {
  SessionStore({FlutterSecureStorage? secureStorage})
    : _secure = secureStorage ?? const FlutterSecureStorage();

  static const _emailKey = 'session_email';
  static const _displayNameKey = 'session_display_name';
  static const _tokenKey = 'session_access_token';

  final FlutterSecureStorage _secure;

  Future<void> save({
    required String email,
    required String displayName,
    String? accessToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
    await prefs.setString(_displayNameKey, displayName);
    if (accessToken != null) await _writeToken(accessToken);
  }

  Future<StoredSession?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_emailKey);
    final displayName = prefs.getString(_displayNameKey);
    if (email == null || displayName == null) return null;
    return StoredSession(
      email: email,
      displayName: displayName,
      accessToken: await _readToken(),
    );
  }

  /// Updates just the greeting name (after the profile loads or is edited).
  Future<void> saveDisplayName(String displayName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_displayNameKey, displayName);
  }

  /// Forgets the token only - the email and name stay, so the app-lock screen can still greet the
  /// user and ask for their password.
  Future<void> clearToken() async {
    try {
      await _secure.delete(key: _tokenKey);
    } catch (_) {}
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_emailKey);
    await prefs.remove(_displayNameKey);
    await clearToken();
  }

  Future<void> _writeToken(String token) async {
    try {
      await _secure.write(key: _tokenKey, value: token);
    } catch (_) {
      // Secure storage can be unavailable (some emulators, a locked keystore). The user then simply
      // signs in with their password next launch.
    }
  }

  Future<String?> _readToken() async {
    try {
      return await _secure.read(key: _tokenKey);
    } catch (_) {
      return null;
    }
  }
}
