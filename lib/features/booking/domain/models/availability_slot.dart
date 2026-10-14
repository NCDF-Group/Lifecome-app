import '../../../../core/utils/formatters.dart';

/// One bookable time with one clinician (`/scheduling/providers/:id/availability`).
class AvailabilitySlot {
  const AvailabilitySlot({
    required this.id,
    required this.providerId,
    required this.startsAt,
    required this.durationMinutes,
  });

  factory AvailabilitySlot.fromJson(Map<String, dynamic> json) =>
      AvailabilitySlot(
        id: json['id'] as String,
        providerId: json['providerId'] as String,
        startsAt: DateTime.parse(json['startsAt'] as String).toUtc(),
        durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 30,
      );

  final String id;
  final String providerId;

  /// The moment it starts, in UTC. Show it with the UK-time helpers on
  /// `Formatters`.
  final DateTime startsAt;
  final int durationMinutes;

  DateTime get endsAt => startsAt.add(Duration(minutes: durationMinutes));

  /// The UK calendar day it falls on (midnight, with no time zone).
  DateTime get ukDay {
    final uk = Formatters.ukTime(startsAt);
    return DateTime(uk.year, uk.month, uk.day);
  }

  /// `10:30`, in UK time.
  String get ukClock => Formatters.time(Formatters.ukTime(startsAt));
}
