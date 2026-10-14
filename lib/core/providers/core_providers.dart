import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/auth_repository.dart';
import '../network/api_client.dart';
import '../services/biometric_service.dart';
import '../services/session_manager.dart';
import '../services/session_store.dart';
import '../storage/secure_storage.dart';

/// Counts how many times the saved sign-in has been rejected by the backend.
/// The app root watches it and sends the person to the sign-in screen.
class SessionExpiredNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final sessionExpiredProvider = NotifierProvider<SessionExpiredNotifier, int>(
  SessionExpiredNotifier.new,
);

/// Changes every time someone signs in or out. Any provider that holds one
/// person's data watches it, so signing out and in as someone else can never
/// show the previous person's records.
class SessionEpoch extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final sessionEpochProvider = NotifierProvider<SessionEpoch, int>(
  SessionEpoch.new,
);

/// Shared Dio-backed client for talking to Lifecome-Backend. Every repository
/// uses this same instance, so they all send the same sign-in token.
final Provider<ApiClient> apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    onSessionExpired: () async {
      await ref.read(sessionManagerProvider).end();
      ref.read(sessionExpiredProvider.notifier).bump();
    },
  );
});

/// The auth repository the rest of the app depends on. Overridden in tests.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return DioAuthRepository(ref.watch(apiClientProvider));
});

/// Remembers the signed-in session between launches (see [SessionStore]).
final sessionStoreProvider = Provider<SessionStore>((ref) => SessionStore());

/// Where a remembered sign-in's token is kept. Overridden in tests.
final tokenStoreProvider = Provider<TokenStore>((ref) => SecureTokenStore());

/// Starts, restores and ends the signed-in session.
final Provider<SessionManager> sessionManagerProvider =
    Provider<SessionManager>((ref) {
      return SessionManager(
        api: ref.watch(apiClientProvider),
        sessions: ref.watch(sessionStoreProvider),
        tokens: ref.watch(tokenStoreProvider),
        onChanged: () => ref.read(sessionEpochProvider.notifier).bump(),
      );
    });

/// Face ID / fingerprint unlock for the app-lock screen.
final biometricServiceProvider = Provider<BiometricService>(
  (ref) => BiometricService(),
);
