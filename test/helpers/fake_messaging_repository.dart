import 'package:lifecome_mobile/core/network/api_exception.dart';
import 'package:lifecome_mobile/features/messaging/data/messaging_repository.dart';
import 'package:lifecome_mobile/features/messaging/domain/models/message_thread.dart';

/// A [MessagingRepository] that answers from memory and records what it was
/// asked. Set the `*Failure` fields to make a call throw.
class FakeMessagingRepository implements MessagingRepository {
  FakeMessagingRepository({
    List<MessageThread>? threads,
    Map<String, List<ThreadMessage>>? messages,
  }) : threads = threads ?? [],
       messages = messages ?? {};

  List<MessageThread> threads;
  Map<String, List<ThreadMessage>> messages;

  Object? listFailure;
  Object? messagesFailure;
  ApiException? createFailure;
  ApiException? sendFailure;

  final List<String> calls = [];
  MessageTopic? lastTopic;
  String? lastBody;

  int _next = 1;

  @override
  Future<List<MessageThread>> listThreads() async {
    calls.add('listThreads');
    final error = listFailure;
    if (error != null) throw error;
    return List.of(threads);
  }

  @override
  Future<(MessageThread, ThreadMessage)> createThread({
    required MessageTopic topic,
    required String body,
  }) async {
    calls.add('createThread');
    lastTopic = topic;
    lastBody = body;
    final error = createFailure;
    if (error != null) throw error;
    final now = DateTime.now().toUtc();
    final id = 'thread-new-${_next++}';
    final message = ThreadMessage(
      id: 'message-$id',
      threadId: id,
      fromPatient: true,
      body: body,
      sentAt: now,
    );
    final thread = MessageThread(
      id: id,
      topic: topic,
      createdAt: now,
    ).withLatest(message);
    threads = [...threads, thread];
    messages[id] = [message];
    return (thread, message);
  }

  @override
  Future<List<ThreadMessage>> listMessages(String threadId) async {
    calls.add('listMessages:$threadId');
    final error = messagesFailure;
    if (error != null) throw error;
    return List.of(messages[threadId] ?? const []);
  }

  @override
  Future<ThreadMessage> sendMessage(String threadId, String body) async {
    calls.add('sendMessage:$threadId');
    lastBody = body;
    final error = sendFailure;
    if (error != null) throw error;
    final message = ThreadMessage(
      id: 'message-${_next++}',
      threadId: threadId,
      fromPatient: true,
      body: body,
      sentAt: DateTime.now().toUtc(),
    );
    messages[threadId] = [...?messages[threadId], message];
    return message;
  }

  /// What the backend would do when the care team replies.
  void reply(String threadId, String body) {
    messages[threadId] = [
      ...?messages[threadId],
      ThreadMessage(
        id: 'message-${_next++}',
        threadId: threadId,
        fromPatient: false,
        body: body,
        sentAt: DateTime.now().toUtc(),
      ),
    ];
  }
}

MessageThread testThread({
  String id = 'thread-1',
  MessageTopic topic = MessageTopic.bookingPayments,
  String lastMessage = 'Can I move my appointment to Friday?',
  Duration age = const Duration(hours: 2),
}) {
  final at = DateTime.now().toUtc().subtract(age);
  return MessageThread(
    id: id,
    topic: topic,
    createdAt: at,
    lastMessage: lastMessage,
    lastMessageAt: at,
  );
}

ThreadMessage testThreadMessage({
  String id = 'm-1',
  String threadId = 'thread-1',
  bool fromPatient = true,
  String body = 'Can I move my appointment to Friday?',
  Duration age = const Duration(hours: 2),
}) => ThreadMessage(
  id: id,
  threadId: threadId,
  fromPatient: fromPatient,
  body: body,
  sentAt: DateTime.now().toUtc().subtract(age),
);
