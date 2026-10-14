import '../../../../core/utils/formatters.dart';

/// What a notification is about: it picks the icon.
enum NotificationKind { booking, message, support, record, other }

/// Where a notification's button leads.
enum NotificationTarget { booking, records, messages }

/// One entry in the patient's in-app notification feed (`/me/notifications`).
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.kind,
    required this.body,
    required this.createdAt,
    this.highlights = const [],
    this.preview,
    this.actionLabel,
    this.target,
    this.actionRef,
    this.readAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    String? text(Object? value) {
      final trimmed = (value as String?)?.trim();
      return trimmed == null || trimmed.isEmpty ? null : trimmed;
    }

    return NotificationItem(
      id: json['id'] as String,
      kind: switch (json['kind']) {
        'booking' => NotificationKind.booking,
        'message' => NotificationKind.message,
        'support' => NotificationKind.support,
        'record' => NotificationKind.record,
        _ => NotificationKind.other,
      },
      body: (json['body'] as String? ?? '').trim(),
      highlights: [
        for (final item in (json['highlights'] as List<dynamic>? ?? const []))
          if (item is String && item.isNotEmpty) item,
      ],
      preview: text(json['preview']),
      actionLabel: text(json['actionLabel']),
      target: switch (json['actionTarget']) {
        'booking' => NotificationTarget.booking,
        'records' => NotificationTarget.records,
        'messages' => NotificationTarget.messages,
        _ => null,
      },
      actionRef: text(json['actionRef']),
      readAt: Formatters.parseInstant(json['readAt']),
      createdAt: Formatters.parseInstant(json['createdAt']) ?? DateTime.now(),
    );
  }

  final String id;
  final NotificationKind kind;
  final String body;

  /// Parts of [body] to show in bold (a clinician's name, a date).
  final List<String> highlights;

  /// A quoted snippet shown in a box under the body (the care team's reply).
  final String? preview;
  final String? actionLabel;
  final NotificationTarget? target;

  /// The id of the booking, thread or record the notification is about.
  final String? actionRef;
  final DateTime? readAt;
  final DateTime createdAt;

  bool get isRead => readAt != null;

  NotificationItem markedRead(DateTime when) => NotificationItem(
    id: id,
    kind: kind,
    body: body,
    highlights: highlights,
    preview: preview,
    actionLabel: actionLabel,
    target: target,
    actionRef: actionRef,
    readAt: readAt ?? when,
    createdAt: createdAt,
  );
}

/// The notification feed and how many entries in it are unread.
class NotificationFeed {
  const NotificationFeed({required this.items, required this.unreadCount});

  factory NotificationFeed.fromJson(Map<String, dynamic> json) =>
      NotificationFeed(
        items: [
          for (final item in (json['items'] as List<dynamic>? ?? const []))
            if (item is Map<String, dynamic>) NotificationItem.fromJson(item),
        ],
        unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      );

  final List<NotificationItem> items;
  final int unreadCount;

  NotificationFeed markRead(String id, DateTime when) {
    var changed = false;
    final updated = [
      for (final item in items)
        if (item.id == id && !item.isRead)
          () {
            changed = true;
            return item.markedRead(when);
          }()
        else
          item,
    ];
    if (!changed) return this;
    return NotificationFeed(
      items: updated,
      unreadCount: unreadCount > 0 ? unreadCount - 1 : 0,
    );
  }

  NotificationFeed markAllRead(DateTime when) => NotificationFeed(
    items: [for (final item in items) item.markedRead(when)],
    unreadCount: 0,
  );
}
