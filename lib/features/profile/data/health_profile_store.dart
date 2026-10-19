import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/providers/core_providers.dart';
import '../application/profile_controller.dart';

/// What the person has noted about their health (screen pack 021).
class HealthProfile {
  const HealthProfile({this.conditions, this.medicines, this.allergies});

  final String? conditions;
  final String? medicines;
  final String? allergies;

  bool get isEmpty =>
      conditions == null && medicines == null && allergies == null;

  /// Medicines and allergies in one line, for the booking intake form.
  String? get medicinesAndAllergies {
    final parts = [
      if (medicines != null) 'Medicines: $medicines',
      if (allergies != null) 'Allergies: $allergies',
    ];
    return parts.isEmpty ? null : parts.join('\n');
  }

  Map<String, String?> toJson() => {
    'conditions': conditions,
    'medicines': medicines,
    'allergies': allergies,
  };

  factory HealthProfile.fromJson(Map<String, dynamic> json) => HealthProfile(
    conditions: json['conditions'] as String?,
    medicines: json['medicines'] as String?,
    allergies: json['allergies'] as String?,
  );
}

/// Keeps the health profile in the phone's encrypted storage, one per
/// account. The backend cannot store it yet, so it never leaves the device
/// except when the person sends it with a booking.
abstract interface class HealthProfileStore {
  Future<HealthProfile> read(String accountId);
  Future<void> save(String accountId, HealthProfile profile);
}

class SecureHealthProfileStore implements HealthProfileStore {
  SecureHealthProfileStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  String _key(String accountId) => 'health_profile_$accountId';

  @override
  Future<HealthProfile> read(String accountId) async {
    final raw = await _storage.read(key: _key(accountId));
    if (raw == null) return const HealthProfile();
    return HealthProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> save(String accountId, HealthProfile profile) =>
      _storage.write(key: _key(accountId), value: jsonEncode(profile.toJson()));
}

/// Kept in memory only; for tests.
class MemoryHealthProfileStore implements HealthProfileStore {
  final _profiles = <String, HealthProfile>{};

  @override
  Future<HealthProfile> read(String accountId) async =>
      _profiles[accountId] ?? const HealthProfile();

  @override
  Future<void> save(String accountId, HealthProfile profile) async =>
      _profiles[accountId] = profile;
}

final healthProfileStoreProvider = Provider<HealthProfileStore>(
  (ref) => SecureHealthProfileStore(),
);

/// The signed-in person's health profile (empty until the account loads).
final healthProfileProvider = FutureProvider<HealthProfile>((ref) async {
  ref.watch(sessionEpochProvider);
  final accountId = ref.watch(meProvider).value?.account.id;
  if (accountId == null) return const HealthProfile();
  return ref.watch(healthProfileStoreProvider).read(accountId);
});
