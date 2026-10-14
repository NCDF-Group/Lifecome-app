import '../../../doctors/domain/models/doctor.dart';
import '../../../payer/domain/models/eligibility_result.dart';
import '../../../payer/domain/models/membership.dart';
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
      plan = null;

  const BookingStart.hmo(LinkedPlan this.plan)
    : accessType = BookingAccessType.hmo,
      doctor = null;

  final BookingAccessType accessType;

  /// The verified health plan that will pay, for an `hmo` booking.
  final LinkedPlan? plan;
  final Doctor? doctor;

  String? get hmoName => plan?.name;
}

/// Accumulates the patient's choices as they move through the booking journey
/// (service, place, clinician, time, details), passed screen-to-screen as a
/// route `extra` and rebuilt with `copyWith` at each step. Nothing is sent to
/// the backend until the review screen creates the appointment.
class BookingSelection {
  const BookingSelection({
    required this.accessType,
    this.plan,
    this.eligibility,
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

  /// The verified health plan paying for the visit, when [accessType] is `hmo`.
  final LinkedPlan? plan;

  /// What that plan said about covering [service], when it has been asked.
  final EligibilityCheck? eligibility;
  final ClinicalService? service;
  final Doctor? doctor;
  final AvailabilitySlot? slot;
  final ConsultationMode mode;

  /// Where the patient is (or, for a clinic visit, wants a clinic).
  final String? city;
  final String? postcode;
  final String? concern;
  final AppointmentIntake? intake;

  String? get hmoName => plan?.name;

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
    EligibilityCheck? eligibility,
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
      plan: plan,
      eligibility: eligibility ?? this.eligibility,
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
