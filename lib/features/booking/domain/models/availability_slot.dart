/// One bookable time for a clinician (`GET /scheduling/providers/:id/availability`).
class AvailabilitySlot {
  const AvailabilitySlot({
    required this.id,
    required this.startsAt,
    required this.durationMinutes,
  });

  final String id;

  /// In UTC; format it in the user's appointment time zone (see `booking_format.dart`).
  final DateTime startsAt;
  final int durationMinutes;

  factory AvailabilitySlot.fromJson(Map<String, dynamic> json) =>
      AvailabilitySlot(
        id: json['id'] as String,
        startsAt: DateTime.parse(json['startsAt'] as String).toUtc(),
        durationMinutes: json['durationMinutes'] as int,
      );
}
