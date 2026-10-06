import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/auth_repository.dart';
import '../network/api_client.dart';
import '../services/biometric_service.dart';
import '../services/session_store.dart';

/// Shared Dio-backed client for talking to Lifecome-Backen. Repositories beyond auth can
/// depend on this same instance once they need it.
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

/// The auth repository the rest of the app depends on. Overridden in tests.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return DioAuthRepository(ref.watch(apiClientProvider));
});

/// Remembers the signed-in session between launches (see [SessionStore]).
final sessionStoreProvider = Provider<SessionStore>((ref) => SessionStore());

/// Face ID / fingerprint unlock for the app-lock screen.
final biometricServiceProvider = Provider<BiometricService>(
  (ref) => BiometricService(),
);
