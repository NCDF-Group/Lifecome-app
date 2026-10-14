import '../../../core/network/api_client.dart';
import '../domain/models/me.dart';
import '../domain/models/patient_profile.dart';

/// Reads and changes the signed-in person's own account and profile
/// (the backend's `/me` endpoints). Failures surface as an `ApiException`.
abstract interface class ProfileRepository {
  Future<Me> getMe();

  /// Creates the profile (the first time) or replaces it — `PUT /me/profile`.
  Future<PatientProfile> saveProfile(ProfileInput input);

  /// Changes a profile that already exists — `PATCH /me/profile`.
  Future<PatientProfile> updateProfile(ProfileInput input);
}

class DioProfileRepository implements ProfileRepository {
  DioProfileRepository(this._client);

  final ApiClient _client;

  @override
  Future<Me> getMe() async => Me.fromJson(await _client.get('/me'));

  @override
  Future<PatientProfile> saveProfile(ProfileInput input) async =>
      PatientProfile.fromJson(
        await _client.put('/me/profile', data: input.toJson()),
      );

  @override
  Future<PatientProfile> updateProfile(ProfileInput input) async =>
      PatientProfile.fromJson(
        await _client.patch('/me/profile', data: input.toJson()),
      );
}
