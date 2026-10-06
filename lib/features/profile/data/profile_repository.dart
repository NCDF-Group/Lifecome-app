import 'dart:convert';
import 'dart:typed_data';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../domain/my_profile.dart';

/// The signed-in patient's own account, profile and profile photo (the backend's `/me` routes).
class ProfileRepository {
  ProfileRepository(this._client);

  final ApiClient _client;

  Future<MyAccount> getMe() async =>
      MyAccount.fromJson(await _client.getMap('/me'));

  /// Creates the profile on first call, replaces it afterwards.
  Future<PatientProfile> saveProfile({
    required String firstName,
    required String lastName,
    required DateTime dateOfBirth,
    String country = 'NG',
  }) async {
    final json = await _client.put(
      '/me/profile',
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'dateOfBirth': _isoDate(dateOfBirth),
        'country': country,
      },
    );
    return PatientProfile.fromJson(json);
  }

  Future<PatientProfile> uploadAvatar(
    Uint8List bytes, {
    required String contentType,
  }) async {
    final json = await _client.put(
      '/me/avatar',
      data: {'contentType': contentType, 'data': base64Encode(bytes)},
    );
    return PatientProfile.fromJson(json);
  }

  Future<void> removeAvatar() async {
    await _client.delete('/me/avatar');
  }

  /// The profile photo bytes, or null if there is none.
  Future<Uint8List?> fetchAvatar() async {
    try {
      return await _client.getBytes('/me/avatar');
    } on ApiException catch (error) {
      if (error.statusCode == 404) return null;
      rethrow;
    }
  }

  static String _isoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
