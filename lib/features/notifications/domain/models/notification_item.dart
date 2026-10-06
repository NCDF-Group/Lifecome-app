/// Which part of the app a notification belongs to; decides its icon and
/// where its action button leads.
enum NotificationKind { booking, message, support, record }

/// Where a notification's button / tap leads.
enum NotificationTarget { booking, records, messages }

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.kind,
    required this.createdAt,
    required this.body,
    this.boldParts = const [],
    this.preview,
    this.actionLabel,
    this.target,
    this.unread = true,
  });

  final String id;
  final NotificationKind kind;
  final DateTime createdAt;
  final String body;

  /// Substrings of [body] shown in bold (a clinician's name, a date).
  final List<String> boldParts;

  /// A quoted message snippet shown in a bordered box under the body.
  final String? preview;

  /// Label of the outlined action button under the body, if any.
  final String? actionLabel;
  final NotificationTarget? target;
  final bool unread;

  /// "Booking", "Messages", "Support", "Records".
  String get title => switch (kind) {
    NotificationKind.booking => 'Booking',
    NotificationKind.message => 'Messages',
    NotificationKind.support => 'Support',
    NotificationKind.record => 'Records',
  };

  /// "Just now", "2 mins ago", "3 hours ago", "Yesterday", or a date.
  String get timeLabel {
    final age = DateTime.now().difference(createdAt);
    if (age.inMinutes < 1) return 'Just now';
    if (age.inMinutes < 60) {
      final m = age.inMinutes;
      return '$m ${m == 1 ? 'min' : 'mins'} ago';
    }
    if (age.inHours < 24) {
      final h = age.inHours;
      return '$h ${h == 1 ? 'hour' : 'hours'} ago';
    }
    if (age.inDays == 1) return 'Yesterday';
    if (age.inDays < 7) return '${age.inDays} days ago';
    final local = createdAt.toLocal();
    return '${local.day}/${local.month}/${local.year}';
  }

  NotificationItem copyWith({bool? unread}) => NotificationItem(
    id: id,
    kind: kind,
    createdAt: createdAt,
    body: body,
    boldParts: boldParts,
    preview: preview,
    actionLabel: actionLabel,
    target: target,
    unread: unread ?? this.unread,
  );

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      NotificationItem(
        id: json['id'] as String,
        kind: NotificationKind.values.firstWhere(
          (k) => k.name == json['kind'],
          orElse: () => NotificationKind.support,
        ),
        createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
        body: json['body'] as String,
        boldParts: (json['highlights'] as List<dynamic>? ?? const [])
            .cast<String>(),
        preview: json['preview'] as String?,
        actionLabel: json['actionLabel'] as String?,
        target: switch (json['actionTarget']) {
          'booking' => NotificationTarget.booking,
          'records' => NotificationTarget.records,
          'messages' => NotificationTarget.messages,
          _ => null,
        },
        unread: json['readAt'] == null,
      );
}
