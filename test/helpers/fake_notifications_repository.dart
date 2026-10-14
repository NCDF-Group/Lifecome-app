import 'package:lifecome_mobile/features/notifications/data/notifications_repository.dart';
import 'package:lifecome_mobile/features/notifications/domain/models/notification_item.dart';

/// A [NotificationsRepository] that answers from memory and records what it
/// was asked. Set [loadFailure] to make loading throw.
class FakeNotificationsRepository implements NotificationsRepository {
  FakeNotificationsRepository([List<NotificationItem>? items])
    : items = items ?? [];

  List<NotificationItem> items;
  Object? loadFailure;
  final List<String> calls = [];

  @override
  Future<NotificationFeed> getFeed() async {
    calls.add('getFeed');
    final error = loadFailure;
    if (error != null) throw error;
    return NotificationFeed(
      items: items,
      unreadCount: items.where((item) => !item.isRead).length,
    );
  }

  @override
  Future<void> markRead(String id) async {
    calls.add('markRead:$id');
  }

  @override
  Future<void> markAllRead() async {
    calls.add('markAllRead');
  }
}

NotificationItem testBookingNotification({bool read = false}) =>
    NotificationItem(
      id: 'n-booking',
      kind: NotificationKind.booking,
      body: 'Your booking with Dr Sam Okoro has been confirmed for Friday 16 October 2026 at 10:30.',
      highlights: const ['Dr Sam Okoro', 'Friday 16 October 2026'],
      actionLabel: 'View Booking',
      target: NotificationTarget.booking,
      actionRef: 'appointment-1',
      readAt: read ? DateTime.now() : null,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    );

NotificationItem testMessageNotification({bool read = false}) =>
    NotificationItem(
      id: 'n-message',
      kind: NotificationKind.support,
      body: 'Sent you a Message',
      preview: 'Thanks for getting in touch. We have updated your plan.',
      target: NotificationTarget.messages,
      actionRef: 'thread-1',
      readAt: read ? DateTime.now() : null,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    );
