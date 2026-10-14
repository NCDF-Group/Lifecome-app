import '../network/api_client.dart';
import '../storage/secure_storage.dart';
import 'session_store.dart';

/// Starts, restores and ends the patient's signed-in session, keeping the
/// three places it lives in step: the [ApiClient] (the token it sends), the
/// [TokenStore] (the token kept in secure storage) and the [SessionStore]
/// (who to greet on the lock screen).
class SessionManager {
  SessionManager({
    required this.api,
    required this.sessions,
    required this.tokens,
    this.onChanged,
  });

  final ApiClient api;
  final SessionStore sessions;
  final TokenStore tokens;

  /// Called after someone signs in or out, so anything holding the previous
  /// person's data can drop it.
  final void Function()? onChanged;

  /// Signs in for this launch. With [remember] the token and name are also
  /// saved, so the next launch opens the lock screen instead of the welcome
  /// screen; without it nothing is kept and the next launch starts signed out.
  Future<void> start({
    required String accessToken,
    required String email,
    required String displayName,
    required bool remember,
  }) async {
    api.accessToken = accessToken;
    if (remember) {
      await tokens.write(accessToken);
      await sessions.save(email: email, displayName: displayName);
    } else {
      await tokens.clear();
      await sessions.clear();
    }
    onChanged?.call();
  }

  /// Puts a remembered token back on the [ApiClient] after the lock screen
  /// unlocks. Returns false when there is none (it was cleared, or secure
  /// storage lost it) — the person then has to enter their password.
  Future<bool> restore() async {
    final token = await tokens.read();
    if (token == null) return false;
    api.accessToken = token;
    onChanged?.call();
    return true;
  }

  /// Signs out: forgets the token everywhere.
  Future<void> end() async {
    api.accessToken = null;
    await tokens.clear();
    await sessions.clear();
    onChanged?.call();
  }
}
