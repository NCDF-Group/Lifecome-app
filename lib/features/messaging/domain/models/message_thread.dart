import '../../../../core/utils/formatters.dart';

/// What a conversation with the care team is about — the choice on "What do
/// you need help with?". The backend's `topic`.
enum MessageTopic {
  bookingPayments('booking_payments', 'Booking and payments'),
  onlineAppointment('online_appointment', 'Online appointment'),
  clinicVisit('clinic_visit', 'Clinic visit'),
  followUp('follow_up', 'Follow-up');

  const MessageTopic(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static MessageTopic? parse(Object? value) {
    for (final topic in values) {
      if (topic.apiValue == value) return topic;
    }
    return null;
  }
}

/// One conversation with the care team (`/message-threads`).
class MessageThread {
  const MessageThread({
    required this.id,
    required this.createdAt,
    this.topic,
    this.subject,
    this.lastMessage,
    this.lastMessageAt,
  });

  factory MessageThread.fromJson(Map<String, dynamic> json) {
    String? text(Object? value) {
      final trimmed = (value as String?)?.trim();
      return trimmed == null || trimmed.isEmpty ? null : trimmed;
    }

    return MessageThread(
      id: json['id'] as String,
      topic: MessageTopic.parse(json['topic']),
      subject: text(json['subject']),
      createdAt: Formatters.parseInstant(json['createdAt']) ?? DateTime.now(),
      lastMessage: text(json['lastMessage']),
      lastMessageAt: Formatters.parseInstant(json['lastMessageAt']),
    );
  }

  final String id;
  final MessageTopic? topic;
  final String? subject;
  final DateTime createdAt;

  /// The newest message's text, for the list.
  final String? lastMessage;
  final DateTime? lastMessageAt;

  String get title => topic?.label ?? subject ?? 'Care team';

  /// When anything last happened in it.
  DateTime get updatedAt => lastMessageAt ?? createdAt;

  MessageThread withLatest(ThreadMessage message) => MessageThread(
    id: id,
    topic: topic,
    subject: subject,
    createdAt: createdAt,
    lastMessage: message.body,
    lastMessageAt: message.sentAt,
  );
}

/// One message in a conversation.
class ThreadMessage {
  const ThreadMessage({
    required this.id,
    required this.threadId,
    required this.fromPatient,
    required this.body,
    required this.sentAt,
  });

  factory ThreadMessage.fromJson(Map<String, dynamic> json) => ThreadMessage(
    id: json['id'] as String,
    threadId: json['threadId'] as String? ?? '',
    fromPatient: json['senderType'] == 'patient',
    body: (json['body'] as String? ?? '').trim(),
    sentAt: Formatters.parseInstant(json['sentAt']) ?? DateTime.now(),
  );

  final String id;
  final String threadId;

  /// False for a reply from the care team.
  final bool fromPatient;
  final String body;
  final DateTime sentAt;
}
