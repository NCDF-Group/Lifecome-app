import '../../../doctors/domain/models/doctor.dart';
import 'availability_slot.dart';
import 'clinical_service.dart';

enum BookingAccessType { hmo, direct }

/// Accumulates the patient's choices as they move through the booking journey, passed
/// screen-to-screen as a route `extra` and rebuilt with `copyWith` at each step. Nothing is sent to the
/// backend until the review step creates the appointment (see `ReviewBookingScreen`).
class BookingSelection {
  const BookingSelection({
    required this.accessType,
    this.hmoName,
    this.service,
    this.doctor,
    this.slot,
    this.date,
    this.time,
    this.consultationType = 'Video consultation',
    this.concern,
    this.location,
    this.intake = const {},
  });

  final BookingAccessType accessType;
  final String? hmoName;
  final ClinicalService? service;
  final Doctor? doctor;

  /// The chosen appointment time; [date] and [time] are the same moment formatted in the patient's
  /// appointment time zone, kept for display.
  final AvailabilitySlot? slot;
  final DateTime? date;
  final String? time;
  final String consultationType;
  final String? concern;

  /// City chosen for an in-person visit ("Lagos", "London").
  final String? location;

  /// The "Prepare for ..." answers (reason, medicinesAndAllergies, ...), sent with the booking.
  final Map<String, dynamic> intake;

  bool get isCovered =>
      accessType == BookingAccessType.hmo &&
      (service?.requiresAuthorisation != true);

  BookingSelection copyWith({
    BookingAccessType? accessType,
    ClinicalService? service,
    Doctor? doctor,
    AvailabilitySlot? slot,
    DateTime? date,
    String? time,
    String? consultationType,
    String? concern,
    String? location,
    Map<String, dynamic>? intake,
  }) {
    return BookingSelection(
      accessType: accessType ?? this.accessType,
      hmoName: hmoName,
      service: service ?? this.service,
      doctor: doctor ?? this.doctor,
      slot: slot ?? this.slot,
      date: date ?? this.date,
      time: time ?? this.time,
      consultationType: consultationType ?? this.consultationType,
      concern: concern ?? this.concern,
      location: location ?? this.location,
      intake: intake ?? this.intake,
    );
  }
}

extension BookingSelectionX on BookingSelection {
  bool get isInPerson => consultationType == 'In-person visit';

  /// What the backend calls this appointment's mode.
  String get apiMode => isInPerson ? 'in_person' : 'video';

  String get apiFundingRoute => switch (accessType) {
    BookingAccessType.direct => 'pay_per_visit',
    BookingAccessType.hmo => 'lifecome_benefits',
  };
}
