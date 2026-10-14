import 'package:lifecome_mobile/core/utils/formatters.dart';
import 'package:lifecome_mobile/features/booking/domain/models/appointment.dart';
import 'package:lifecome_mobile/features/booking/domain/models/availability_slot.dart';
import 'package:lifecome_mobile/features/booking/domain/models/booking_status.dart';
import 'package:lifecome_mobile/features/booking/domain/models/clinical_service.dart';
import 'package:lifecome_mobile/features/booking/domain/models/consultation_mode.dart';
import 'package:lifecome_mobile/features/doctors/domain/models/doctor.dart';

// Test data. None of this ships in the app: the screens get all of it from the
// backend, and the tests stand in for the backend with these.

const testServices = [
  ClinicalService(
    id: 'svc-gp',
    code: 'GP_CONSULTATION',
    name: 'GP Consultation',
    description: 'Talk through a new health concern.',
    durationMinutes: 30,
    priceMinor: 6000,
  ),
  ClinicalService(
    id: 'svc-follow-up',
    code: 'FOLLOW_UP',
    name: 'Follow-up Visit',
    description: 'Review progress with your doctor.',
    durationMinutes: 20,
    priceMinor: 4500,
  ),
];

const testDoctorOkoro = Doctor(
  id: 'doc-okoro',
  name: 'Dr Sam Okoro',
  specialty: 'General Practitioner',
  languages: ['English', 'Igbo'],
  modes: {ConsultationMode.video, ConsultationMode.audio},
);

const testDoctorPatel = Doctor(
  id: 'doc-patel',
  name: 'Dr Priya Patel',
  specialty: 'General Practitioner',
  languages: ['English', 'Gujarati'],
  modes: {ConsultationMode.video, ConsultationMode.inPerson},
  city: 'Leeds',
  state: 'West Yorkshire',
);

const testDoctors = [testDoctorOkoro, testDoctorPatel];

/// A slot [days] days from today at [hourUtc]:00 UTC (a quarter past on the
/// hour so it never lands on a day boundary in UK time).
AvailabilitySlot testSlot(
  String id,
  String providerId, {
  required int days,
  int hourUtc = 10,
}) {
  final now = DateTime.now().toUtc();
  final day = DateTime.utc(now.year, now.month, now.day + days, hourUtc, 15);
  return AvailabilitySlot(
    id: id,
    providerId: providerId,
    startsAt: day,
    durationMinutes: 30,
  );
}

/// `10:15` style UK clock for a slot, the way the screens show it.
String ukClock(AvailabilitySlot slot) =>
    Formatters.time(Formatters.ukTime(slot.startsAt));

Appointment testAppointment({
  String id = 'aaaaaaaa-1111-2222-3333-444444444444',
  BookingStatus status = BookingStatus.confirmed,
  ConsultationMode mode = ConsultationMode.video,
  DateTime? startsAt,
  DateTime? createdAt,
  String providerName = 'Dr Sam Okoro',
  String serviceName = 'GP Consultation',
  AppointmentIntake? intake,
}) {
  return Appointment(
    id: id,
    providerId: 'doc-okoro',
    providerName: providerName,
    clinicalServiceId: 'svc-gp',
    serviceName: serviceName,
    availabilitySlotId: 'slot-1',
    startsAt: startsAt ?? DateTime.now().toUtc().add(const Duration(days: 2)),
    durationMinutes: 30,
    mode: mode,
    status: status,
    fundingRoute: FundingRoute.payPerVisit,
    createdAt:
        createdAt ?? DateTime.now().toUtc().subtract(const Duration(hours: 1)),
    presentingConcern: 'A cough that will not go away',
    intake: intake,
  );
}
