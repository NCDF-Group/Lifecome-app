import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/booking/data/booking_repository.dart';
import '../../features/messaging/data/messaging_repository.dart';
import '../../features/notifications/data/notifications_repository.dart';
import '../../features/profile/data/profile_repository.dart';
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

/// The signed-in patient's own account, profile and photo (`/me`).
final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(apiClientProvider)),
);

/// Messages to the care team.
final messagingRepositoryProvider = Provider<MessagingRepository>(
  (ref) => MessagingRepository(ref.watch(apiClientProvider)),
);

/// Services, clinicians, availability and appointments.
final bookingRepositoryProvider = Provider<BookingRepository>(
  (ref) => BookingRepository(ref.watch(apiClientProvider)),
);

/// The in-app notification feed.
final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => NotificationsRepository(ref.watch(apiClientProvider)),
);
