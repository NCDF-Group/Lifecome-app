import 'package:local_auth/local_auth.dart';

/// Thin wrapper around `local_auth` for the app-lock screen. Never throws:
/// any platform error (no biometrics enrolled, hardware unavailable, user
/// cancelled) is treated the same as "unlock failed", so the screen always
/// falls back to the password field instead of crashing.
class BiometricService {
  final _localAuth = LocalAuthentication();

  Future<bool> isAvailable() async {
    try {
      final supported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;
      return supported && canCheck;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Unlock LifeCome Live',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }
}
