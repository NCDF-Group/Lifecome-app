import '../../../core/network/api_client.dart';
import '../domain/models/message_thread.dart';

/// The patient's conversations with the care team (the backend's
/// `/message-threads`). Failures surface as an `ApiException`.
abstract interface class MessagingRepository {
  Future<List<MessageThread>> listThreads();

  /// Starts a conversation about [topic] with a first message.
  Future<(MessageThread, ThreadMessage)> createThread({
    required MessageTopic topic,
    required String body,
  });

  /// A conversation's messages, oldest first.
  Future<List<ThreadMessage>> listMessages(String threadId);

  Future<ThreadMessage> sendMessage(String threadId, String body);
}

class DioMessagingRepository implements MessagingRepository {
  DioMessagingRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<MessageThread>> listThreads() async {
    final rows = await _client.getList('/message-threads');
    return [
      for (final row in rows)
        if (row is Map<String, dynamic>) MessageThread.fromJson(row),
    ];
  }

  @override
  Future<(MessageThread, ThreadMessage)> createThread({
    required MessageTopic topic,
    required String body,
  }) async {
    final json = await _client.post(
      '/message-threads',
      data: {'topic': topic.apiValue, 'body': body},
    );
    final message = ThreadMessage.fromJson(
      json['message'] as Map<String, dynamic>,
    );
    final thread = MessageThread.fromJson(
      json['thread'] as Map<String, dynamic>,
    ).withLatest(message);
    return (thread, message);
  }

  @override
  Future<List<ThreadMessage>> listMessages(String threadId) async {
    final rows = await _client.getList('/message-threads/$threadId/messages');
    return [
      for (final row in rows)
        if (row is Map<String, dynamic>) ThreadMessage.fromJson(row),
    ]..sort((a, b) => a.sentAt.compareTo(b.sentAt));
  }

  @override
  Future<ThreadMessage> sendMessage(String threadId, String body) async =>
      ThreadMessage.fromJson(
        await _client.post(
          '/message-threads/$threadId/messages',
          data: {'body': body},
        ),
      );
}
