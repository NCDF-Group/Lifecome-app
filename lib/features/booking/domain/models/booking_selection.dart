import '../../../doctors/domain/models/doctor.dart';
import 'appointment.dart';
import 'availability_slot.dart';
import 'booking_status.dart';
import 'clinical_service.dart';
import 'consultation_mode.dart';

enum BookingAccessType { hmo, direct }

/// Where a booking begins: how it will be paid for and, when it starts from
/// the clinic finder, the clinician already chosen.
class BookingStart {
  const BookingStart.direct({this.doctor})
    : accessType = BookingAccessType.direct,
      hmoName = null;

  const BookingStart.hmo(String this.hmoName)
    : accessType = BookingAccessType.hmo,
      doctor = null;

  final BookingAccessType accessType;
  final String? hmoName;
  final Doctor? doctor;
}

/// Accumulates the patient's choices as they move through the booking journey
/// (service, place, clinician, time, details), passed screen-to-screen as a
/// route `extra` and rebuilt with `copyWith` at each step. Nothing is sent to
/// the backend until the review screen creates the appointment.
class BookingSelection {
  const BookingSelection({
    required this.accessType,
    this.hmoName,
    this.service,
    this.doctor,
    this.slot,
    this.mode = ConsultationMode.video,
    this.city,
    this.postcode,
    this.concern,
    this.intake,
  });

  final BookingAccessType accessType;

  /// The health plan paying for the visit, when [accessType] is `hmo`.
  final String? hmoName;
  final ClinicalService? service;
  final Doctor? doctor;
  final AvailabilitySlot? slot;
  final ConsultationMode mode;

  /// Where the patient is (or, for a clinic visit, wants a clinic).
  final String? city;
  final String? postcode;
  final String? concern;
  final AppointmentIntake? intake;

  FundingRoute get fundingRoute => accessType == BookingAccessType.hmo
      ? FundingRoute.lifecomeBenefits
      : FundingRoute.payPerVisit;

  /// Everything needed to create the appointment has been chosen.
  bool get isComplete => service != null && doctor != null && slot != null;

  /// The request for `POST /appointments`, or null until [isComplete].
  NewAppointment? toRequest() {
    if (!isComplete) return null;
    return NewAppointment(
      providerId: doctor!.id,
      clinicalServiceId: service!.id,
      availabilitySlotId: slot!.id,
      mode: mode,
      fundingRoute: fundingRoute,
      presentingConcern: concern,
      locationCity: mode == ConsultationMode.inPerson ? city : null,
      intake: intake,
    );
  }

  BookingSelection copyWith({
    ClinicalService? service,
    Doctor? doctor,
    AvailabilitySlot? slot,
    ConsultationMode? mode,
    String? city,
    String? postcode,
    String? concern,
    AppointmentIntake? intake,
    bool clearSlot = false,
  }) {
    return BookingSelection(
      accessType: accessType,
      hmoName: hmoName,
      service: service ?? this.service,
      doctor: doctor ?? this.doctor,
      slot: clearSlot ? null : (slot ?? this.slot),
      mode: mode ?? this.mode,
      city: city ?? this.city,
      postcode: postcode ?? this.postcode,
      concern: concern ?? this.concern,
      intake: intake ?? this.intake,
    );
  }
}
