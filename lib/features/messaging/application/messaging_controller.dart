import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/messaging_repository.dart';
import '../domain/models/message_thread.dart';

/// The messaging repository the screens depend on. Overridden in tests.
final messagingRepositoryProvider = Provider<MessagingRepository>((ref) {
  return DioMessagingRepository(ref.watch(apiClientProvider));
});

/// The person's conversations with the care team, most recently active
/// first. Starts over whenever someone signs in or out.
class ThreadsNotifier extends AsyncNotifier<List<MessageThread>> {
  @override
  Future<List<MessageThread>> build() async {
    ref.watch(sessionEpochProvider);
    return _sorted(await ref.watch(messagingRepositoryProvider).listThreads());
  }

  List<MessageThread> _sorted(List<MessageThread> threads) =>
      [...threads]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  /// Loads the list again, keeping what is on screen until the answer arrives.
  Future<void> refresh() async {
    final repository = ref.read(messagingRepositoryProvider);
    state = await AsyncValue.guard(
      () async => _sorted(await repository.listThreads()),
    );
  }

  /// Starts a conversation and puts it at the top of the list. Throws an
  /// `ApiException` if the backend refuses.
  Future<MessageThread> start({
    required MessageTopic topic,
    required String body,
  }) async {
    final (thread, _) = await ref
        .read(messagingRepositoryProvider)
        .createThread(topic: topic, body: body);
    _put(thread);
    return thread;
  }

  /// Notes the newest message in a conversation, so the list shows it.
  void noteLatest(String threadId, ThreadMessage message) {
    final current = state.value;
    if (current == null) return;
    for (final thread in current) {
      if (thread.id == threadId) {
        _put(thread.withLatest(message));
        return;
      }
    }
  }

  void _put(MessageThread thread) {
    final current = state.value ?? const <MessageThread>[];
    state = AsyncData(
      _sorted([
        for (final existing in current)
          if (existing.id != thread.id) existing,
        thread,
      ]),
    );
  }
}

final threadsProvider =
    AsyncNotifierProvider<ThreadsNotifier, List<MessageThread>>(
      ThreadsNotifier.new,
    );

/// One conversation's messages. The thread screen polls it for the care
/// team's replies while it is open.
class ThreadMessagesNotifier extends AsyncNotifier<List<ThreadMessage>> {
  ThreadMessagesNotifier(this.threadId);

  final String threadId;

  @override
  Future<List<ThreadMessage>> build() {
    ref.watch(sessionEpochProvider);
    return ref.watch(messagingRepositoryProvider).listMessages(threadId);
  }

  /// Loads the messages again. A failed poll keeps what is on screen.
  Future<void> poll() async {
    try {
      final messages = await ref
          .read(messagingRepositoryProvider)
          .listMessages(threadId);
      state = AsyncData(messages);
    } catch (_) {
      // Keep the messages already shown.
    }
  }

  /// Sends a message and adds it to the conversation. Throws an
  /// `ApiException` if the backend refuses, so the text is not lost.
  Future<void> send(String body) async {
    final message = await ref
        .read(messagingRepositoryProvider)
        .sendMessage(threadId, body);
    state = AsyncData([...?state.value, message]);
    ref.read(threadsProvider.notifier).noteLatest(threadId, message);
  }
}

final threadMessagesProvider = AsyncNotifierProvider.autoDispose
    .family<ThreadMessagesNotifier, List<ThreadMessage>, String>(
      ThreadMessagesNotifier.new,
    );
