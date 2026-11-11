import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers/core_providers.dart';

/// Short-lived credentials returned by the backend for one participant.
/// Keep these in memory only; the Daily API key never belongs in the app.
class DailyCallCredentials {
  const DailyCallCredentials({
    required this.roomUrl,
    required this.token,
    this.expiresAt,
  });

  factory DailyCallCredentials.fromJson(Map<String, dynamic> json) {
    final roomUrl = json['roomUrl'];
    final token = json['token'];
    if (roomUrl is! String || token is! String) {
      throw const FormatException(
        'The server returned invalid call credentials.',
      );
    }
    return DailyCallCredentials(
      roomUrl: roomUrl,
      token: token,
      expiresAt: DateTime.tryParse(json['expiresAt'] as String? ?? '')?.toUtc(),
    );
  }

  final String roomUrl;
  final String token;
  final DateTime? expiresAt;
}

abstract interface class DailyCallRepository {
  Future<DailyCallCredentials> joinPatientCall(String appointmentId);
}

class DioDailyCallRepository implements DailyCallRepository {
  DioDailyCallRepository(this._client);

  final ApiClient _client;

  @override
  Future<DailyCallCredentials> joinPatientCall(String appointmentId) async =>
      DailyCallCredentials.fromJson(
        await _client.post('/appointments/$appointmentId/consultation/join'),
      );
}

final dailyCallRepositoryProvider = Provider<DailyCallRepository>((ref) {
  return DioDailyCallRepository(ref.watch(apiClientProvider));
});
