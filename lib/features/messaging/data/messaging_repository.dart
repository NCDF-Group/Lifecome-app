import '../../../core/network/api_client.dart';

/// The patient's conversations with the care team (the backend's `/message-threads`).
class MessagingRepository {
  MessagingRepository(this._client);

  final ApiClient _client;

  /// Starts a conversation about [topic] (`booking_payments`, `online_appointment`, `clinic_visit` or
  /// `follow_up`) with [body] as the first message.
  Future<void> startThread({
    required String topic,
    required String body,
  }) async {
    await _client.post(
      '/message-threads',
      data: {'topic': topic, 'body': body},
    );
  }
}
