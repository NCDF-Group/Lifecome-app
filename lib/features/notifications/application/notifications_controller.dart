import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/notification_item.dart';

/// The user's notifications, newest first.
///
/// There is no notifications backend yet, so release builds start empty
/// (the screen shows its empty state). Debug builds are seeded with sample
/// items so the screen's design can be reviewed.
class NotificationsController extends Notifier<List<NotificationItem>> {
  @override
  List<NotificationItem> build() => kDebugMode ? _sample : const [];

  void markAllRead() {
    state = [for (final item in state) item.copyWith(unread: false)];
  }

  void markRead(String id) {
    state = [
      for (final item in state)
        if (item.id == id) item.copyWith(unread: false) else item,
    ];
  }
}

final notificationsProvider =
    NotifierProvider<NotificationsController, List<NotificationItem>>(
      NotificationsController.new,
    );

/// True while any notification is unread — drives the red dot on the bell.
final hasUnreadNotificationsProvider = Provider<bool>(
  (ref) => ref.watch(notificationsProvider).any((item) => item.unread),
);

const _sample = [
  NotificationItem(
    id: 'n1',
    kind: NotificationKind.booking,
    title: 'Booking',
    timeLabel: 'Just now',
    body:
        'Your booking with Dr. Zainab has been confirmed for 12 October, 2026.',
    boldParts: ['Dr. Zainab', '12 October, 2026'],
    actionLabel: 'View Booking',
  ),
  NotificationItem(
    id: 'n2',
    kind: NotificationKind.message,
    title: 'Messages',
    timeLabel: '2 mins ago',
    body: 'Dr. Samuel Sent you a Message',
    boldParts: ['Dr. Samuel'],
    preview: 'Please make sure to stick to the prescription for the month.',
  ),
  NotificationItem(
    id: 'n3',
    kind: NotificationKind.support,
    title: 'Support',
    timeLabel: '2 mins ago',
    body: 'Sent you a Message',
    preview:
        "We've addressed your issue, please let us know if you need more help.",
  ),
  NotificationItem(
    id: 'n4',
    kind: NotificationKind.record,
    title: 'Records',
    timeLabel: '3 hours ago',
    body: 'Your medical records was just updated.',
    actionLabel: 'View Records',
  ),
];
