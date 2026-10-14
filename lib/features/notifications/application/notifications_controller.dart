import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/notifications_repository.dart';
import '../domain/models/notification_item.dart';

/// The notifications repository the screens depend on. Overridden in tests.
final notificationsRepositoryProvider = Provider<NotificationsRepository>((
  ref,
) {
  return DioNotificationsRepository(ref.watch(apiClientProvider));
});

/// The signed-in person's notification feed. Starts over whenever someone
/// signs in or out, so one person's notifications are never shown to the next.
class NotificationsNotifier extends AsyncNotifier<NotificationFeed> {
  @override
  Future<NotificationFeed> build() {
    ref.watch(sessionEpochProvider);
    return ref.watch(notificationsRepositoryProvider).getFeed();
  }

  /// Loads the feed again, keeping what is on screen until the answer arrives.
  Future<void> refresh() async {
    final repository = ref.read(notificationsRepositoryProvider);
    state = await AsyncValue.guard(repository.getFeed);
  }

  /// Marks one notification read straight away, and tells the backend. If the
  /// backend refuses it goes back to unread, so the bell never lies.
  Future<void> markRead(String id) async {
    final before = state.value;
    if (before == null) return;
    final after = before.markRead(id, DateTime.now());
    if (identical(after, before)) return;
    state = AsyncData(after);
    try {
      await ref.read(notificationsRepositoryProvider).markRead(id);
    } catch (_) {
      state = AsyncData(before);
    }
  }

  Future<void> markAllRead() async {
    final before = state.value;
    if (before == null || before.unreadCount == 0) return;
    state = AsyncData(before.markAllRead(DateTime.now()));
    try {
      await ref.read(notificationsRepositoryProvider).markAllRead();
    } catch (_) {
      state = AsyncData(before);
    }
  }
}

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, NotificationFeed>(
      NotificationsNotifier.new,
    );
