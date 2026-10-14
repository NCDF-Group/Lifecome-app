import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/profile_repository.dart';
import '../domain/models/me.dart';
import '../domain/models/patient_profile.dart';

/// The profile repository the screens depend on. Overridden in tests.
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return DioProfileRepository(ref.watch(apiClientProvider));
});

/// The signed-in person's account and profile, loaded once and kept until they
/// sign out. Starts over whenever someone signs in or out, so one person's
/// details are never shown to the next.
class MeNotifier extends AsyncNotifier<Me> {
  @override
  Future<Me> build() {
    ref.watch(sessionEpochProvider);
    return ref.watch(profileRepositoryProvider).getMe();
  }

  /// Loads it again, keeping what is on screen until the answer arrives.
  Future<void> refresh() async {
    final repository = ref.read(profileRepositoryProvider);
    state = await AsyncValue.guard(repository.getMe);
  }

  /// Creates the profile (when there is none yet) or changes it, and puts the
  /// result straight into [state] so every screen shows the new details.
  /// Throws an `ApiException` if the backend refuses.
  Future<PatientProfile> saveProfile(ProfileInput input) async {
    final repository = ref.read(profileRepositoryProvider);
    final current = state.value;
    final saved = current?.profile == null
        ? await repository.saveProfile(input)
        : await repository.updateProfile(input);
    if (current != null) {
      state = AsyncData(current.withProfile(saved));
    } else {
      await refresh();
    }
    return saved;
  }
}

final meProvider = AsyncNotifierProvider<MeNotifier, Me>(MeNotifier.new);
