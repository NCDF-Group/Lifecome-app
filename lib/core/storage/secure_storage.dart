import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Where the patient's access token is kept between launches, so a remembered
/// sign-in can use the backend again after Face ID / fingerprint unlock
/// without asking for the password.
///
/// Behind an interface so tests (and the "don't remember me" case) can use
/// [MemoryTokenStore] instead of the device's secure storage.
abstract interface class TokenStore {
  Future<String?> read();
  Future<void> write(String token);
  Future<void> clear();
}

/// Keeps the token in the iOS Keychain / Android Keystore-backed storage —
/// never in plain preferences, since it unlocks someone's health record.
///
/// A storage failure (a corrupted keystore, a restore onto a new phone) is
/// treated as "no saved sign-in": the person just signs in again.
class SecureTokenStore implements TokenStore {
  SecureTokenStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'access_token';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() async {
    try {
      return await _storage.read(key: _key);
    } on Exception {
      return null;
    }
  }

  @override
  Future<void> write(String token) async {
    try {
      await _storage.write(key: _key, value: token);
    } on Exception {
      // Nothing to do: the sign-in works for this launch, it just won't be
      // remembered.
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _storage.delete(key: _key);
    } on Exception {
      // Same as above.
    }
  }
}

/// A token held in memory only. Used by tests.
class MemoryTokenStore implements TokenStore {
  String? _token;

  @override
  Future<String?> read() async => _token;

  @override
  Future<void> write(String token) async => _token = token;

  @override
  Future<void> clear() async => _token = null;
}
