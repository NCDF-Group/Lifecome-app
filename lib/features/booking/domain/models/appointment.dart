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
  });

  final BookingAccessType accessType;
  final String? hmoName;
  final ClinicalService? service;
  final Doctor? doctor;
  final DateTime? date;
  final String? time;
  final String consultationType;
  final String? concern;

  bool get isCovered =>
      accessType == BookingAccessType.hmo &&
      (service?.requiresAuthorisation != true);

  BookingSelection copyWith({
    ClinicalService? service,
    Doctor? doctor,
    DateTime? date,
    String? time,
    String? consultationType,
    String? concern,
  }) {
    return BookingSelection(
      accessType: accessType,
      hmoName: hmoName,
      service: service ?? this.service,
      doctor: doctor ?? this.doctor,
      date: date ?? this.date,
      time: time ?? this.time,
      consultationType: consultationType ?? this.consultationType,
      concern: concern ?? this.concern,
    );
  }
}
