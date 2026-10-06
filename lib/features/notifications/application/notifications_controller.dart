import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../domain/models/notification_item.dart';

/// How often the feed is re-fetched while the app is open, so a booking confirmation or a care-team reply
/// shows up (and the bell's red dot appears) without the user doing anything.
const _pollEvery = Duration(seconds: 45);

/// The patient's notifications, newest first.
class NotificationsController extends AsyncNotifier<List<NotificationItem>> {
  @override
  Future<List<NotificationItem>> build() async {
    // Nothing to load (or poll) until there is a session token.
    if (ref.watch(apiClientProvider).accessToken == null) return const [];

    final timer = Timer.periodic(_pollEvery, (_) => refresh());
    ref.onDispose(timer.cancel);

    return ref.read(notificationsRepositoryProvider).list();
  }

  /// Re-fetches quietly: the current list stays on screen, and a failed refresh keeps it too.
  Future<void> refresh() async {
    if (ref.read(apiClientProvider).accessToken == null) return;
    try {
      state = AsyncData(await ref.read(notificationsRepositoryProvider).list());
    } on ApiException {
      // Keep what we have; the next poll tries again.
    }
  }

  Future<void> markRead(String id) async {
    final current = state.value ?? const <NotificationItem>[];
    state = AsyncData([
      for (final item in current)
        if (item.id == id) item.copyWith(unread: false) else item,
    ]);
    try {
      await ref.read(notificationsRepositoryProvider).markRead(id);
    } on ApiException {
      await refresh();
    }
  }

  Future<void> markAllRead() async {
    final current = state.value ?? const <NotificationItem>[];
    state = AsyncData([
      for (final item in current) item.copyWith(unread: false),
    ]);
    try {
      await ref.read(notificationsRepositoryProvider).markAllRead();
    } on ApiException {
      await refresh();
    }
  }
}

final notificationsProvider =
    AsyncNotifierProvider<NotificationsController, List<NotificationItem>>(
      NotificationsController.new,
    );

/// True while any notification is unread - drives the red dot on the bell.
final hasUnreadNotificationsProvider = Provider<bool>(
  (ref) => (ref.watch(notificationsProvider).value ?? const []).any(
    (item) => item.unread,
  ),
);
