/// Which part of the app a notification belongs to; decides its icon and
/// where its action button leads.
enum NotificationKind { booking, message, support, record }

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.timeLabel,
    required this.body,
    this.boldParts = const [],
    this.preview,
    this.actionLabel,
    this.unread = true,
  });

  final String id;
  final NotificationKind kind;

  /// "Booking", "Messages", "Support", "Records".
  final String title;

  /// "Just now", "2 mins ago" — already formatted for display.
  final String timeLabel;
  final String body;

  /// Substrings of [body] shown in bold (a doctor's name, a date).
  final List<String> boldParts;

  /// A quoted message snippet shown in a bordered box under the body.
  final String? preview;

  /// Label of the outlined action button under the body, if any.
  final String? actionLabel;
  final bool unread;

  NotificationItem copyWith({bool? unread}) => NotificationItem(
    id: id,
    kind: kind,
    title: title,
    timeLabel: timeLabel,
    body: body,
    boldParts: boldParts,
    preview: preview,
    actionLabel: actionLabel,
    unread: unread ?? this.unread,
  );
}
