import '../../../doctors/domain/models/doctor.dart';
import 'clinical_service.dart';

enum BookingAccessType { hmo, direct }

/// Accumulates the patient's choices as they move through the booking
/// journey (views 09-17 in the blueprint), passed screen-to-screen as a
/// route `extra` and rebuilt with `copyWith` at each step — there is no
/// booking backend yet to persist this against instead.
class BookingSelection {
  const BookingSelection({
    required this.accessType,
    this.hmoName,
    this.service,
    this.doctor,
    this.date,
    this.time,
    this.consultationType = 'Video consultation',
    this.concern,
    this.location,
  });

  final BookingAccessType accessType;
  final String? hmoName;
  final ClinicalService? service;
  final Doctor? doctor;
  final DateTime? date;
  final String? time;
  final String consultationType;
  final String? concern;

  /// City chosen for an in-person visit ("Lagos", "London").
  final String? location;

  bool get isCovered =>
      accessType == BookingAccessType.hmo &&
      (service?.requiresAuthorisation != true);

  BookingSelection copyWith({
    BookingAccessType? accessType,
    ClinicalService? service,
    Doctor? doctor,
    DateTime? date,
    String? time,
    String? consultationType,
    String? concern,
    String? location,
  }) {
    return BookingSelection(
      accessType: accessType ?? this.accessType,
      hmoName: hmoName,
      service: service ?? this.service,
      doctor: doctor ?? this.doctor,
      date: date ?? this.date,
      time: time ?? this.time,
      consultationType: consultationType ?? this.consultationType,
      concern: concern ?? this.concern,
      location: location ?? this.location,
    );
  }
}

extension BookingSelectionX on BookingSelection {
  bool get isInPerson => consultationType == 'In-person visit';
}
