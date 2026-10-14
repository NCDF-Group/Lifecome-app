import 'package:lifecome_mobile/core/network/api_exception.dart';
import 'package:lifecome_mobile/features/booking/data/booking_repository.dart';
import 'package:lifecome_mobile/features/booking/domain/models/appointment.dart';
import 'package:lifecome_mobile/features/booking/domain/models/availability_slot.dart';
import 'package:lifecome_mobile/features/booking/domain/models/booking_status.dart';
import 'package:lifecome_mobile/features/booking/domain/models/clinical_service.dart';
import 'package:lifecome_mobile/features/consultation/data/consultation_repository.dart';
import 'package:lifecome_mobile/features/consultation/domain/models/consultation_session.dart';
import 'package:lifecome_mobile/features/consultation/domain/models/consultation_status.dart';
import 'package:lifecome_mobile/features/doctors/data/doctor_repository.dart';
import 'package:lifecome_mobile/features/doctors/domain/models/doctor.dart';
import 'package:lifecome_mobile/features/payment/domain/models/payment_status.dart';
import 'package:lifecome_mobile/features/payment/domain/models/payment_transaction.dart';

import 'fixtures.dart';

/// A [BookingRepository] that answers from memory and records what it was
/// asked. Set the `*Failure` fields to make a call throw.
class FakeBookingRepository implements BookingRepository {
  FakeBookingRepository({
    List<ClinicalService>? services,
    Map<String, List<AvailabilitySlot>>? availability,
    List<Appointment>? appointments,
  }) : services = services ?? testServices,
       availability = availability ?? {},
       appointments = appointments ?? [];

  List<ClinicalService> services;
  Map<String, List<AvailabilitySlot>> availability;
  List<Appointment> appointments;

  Object? listFailure;
  ApiException? createFailure;
  ApiException? paymentFailure;
  ApiException? confirmFailure;
  ApiException? cancelFailure;

  final List<String> calls = [];
  NewAppointment? lastRequest;
  String? lastCreateKey;
  String? lastPaymentKey;

  @override
  Future<List<ClinicalService>> listServices() async {
    calls.add('listServices');
    final error = listFailure;
    if (error != null) throw error;
    return services;
  }

  @override
  Future<List<AvailabilitySlot>> listAvailability(String providerId) async {
    calls.add('listAvailability:$providerId');
    return availability[providerId] ?? const [];
  }

  @override
  Future<List<Appointment>> listAppointments() async {
    calls.add('listAppointments');
    final error = listFailure;
    if (error != null) throw error;
    return List.of(appointments);
  }

  @override
  Future<Appointment> createAppointment(
    NewAppointment request, {
    required String idempotencyKey,
    required String providerName,
    required String serviceName,
    required AvailabilitySlot slot,
  }) async {
    calls.add('createAppointment');
    lastRequest = request;
    lastCreateKey = idempotencyKey;
    final error = createFailure;
    if (error != null) throw error;
    final appointment = Appointment(
      id: 'bbbbbbbb-1111-2222-3333-444444444444',
      providerId: request.providerId,
      providerName: providerName,
      clinicalServiceId: request.clinicalServiceId,
      serviceName: serviceName,
      availabilitySlotId: request.availabilitySlotId,
      startsAt: slot.startsAt,
      durationMinutes: slot.durationMinutes,
      mode: request.mode,
      status: BookingStatus.slotHeld,
      fundingRoute: request.fundingRoute,
      createdAt: DateTime.now().toUtc(),
      presentingConcern: request.presentingConcern,
      locationCity: request.locationCity,
      intake: request.intake,
    );
    appointments = [...appointments, appointment];
    return appointment;
  }

  @override
  Future<Appointment> confirmAppointment(
    Appointment appointment, {
    required String idempotencyKey,
  }) async {
    calls.add('confirmAppointment');
    final error = confirmFailure;
    if (error != null) throw error;
    return _set(appointment, BookingStatus.confirmed);
  }

  @override
  Future<Appointment> cancelAppointment(Appointment appointment) async {
    calls.add('cancelAppointment');
    final error = cancelFailure;
    if (error != null) throw error;
    return _set(appointment, BookingStatus.cancelled);
  }

  @override
  Future<PaymentTransaction> createPaymentIntent({
    required Appointment appointment,
    required String idempotencyKey,
  }) async {
    calls.add('createPaymentIntent');
    lastPaymentKey = idempotencyKey;
    final error = paymentFailure;
    if (error != null) throw error;
    return PaymentTransaction(
      id: 'pay-1',
      appointmentId: appointment.id,
      amountMinor: 6000,
      gateway: 'paystack',
      status: PaymentStatus.pending,
      gatewayReference: 'sim_1',
    );
  }

  /// What the backend would do when the payment webhook arrives.
  void confirmOnServer(String appointmentId) {
    appointments = [
      for (final item in appointments)
        if (item.id == appointmentId)
          item.copyWith(status: BookingStatus.confirmed)
        else
          item,
    ];
  }

  Appointment _set(Appointment appointment, BookingStatus status) {
    final updated = appointment.copyWith(status: status);
    appointments = [
      for (final item in appointments)
        if (item.id == appointment.id) updated else item,
    ];
    return updated;
  }
}

class FakeDoctorRepository implements DoctorRepository {
  FakeDoctorRepository([List<Doctor>? doctors])
    : doctors = doctors ?? testDoctors;

  List<Doctor> doctors;
  Object? failure;

  @override
  Future<List<Doctor>> listDoctors() async {
    final error = failure;
    if (error != null) throw error;
    return doctors;
  }

  @override
  Future<Doctor> getDoctor(String id) async =>
      doctors.firstWhere((doctor) => doctor.id == id);
}

class FakeConsultationRepository implements ConsultationRepository {
  FakeConsultationRepository({
    this.status = ConsultationStatus.booked,
    this.startedAt,
  });

  ConsultationStatus status;
  DateTime? startedAt;
  ApiException? transitionFailure;
  final List<String> calls = [];

  ConsultationSession get _session => ConsultationSession(
    id: 'session-1',
    appointmentId: 'apt',
    status: status,
    startedAt: startedAt,
  );

  @override
  Future<ConsultationSession> getSession(String appointmentId) async {
    calls.add('getSession');
    return _session;
  }

  @override
  Future<ConsultationSession> transition(
    String appointmentId,
    ConsultationStatus next,
  ) async {
    calls.add('transition:${next.apiValue}');
    final error = transitionFailure;
    if (error != null) throw error;
    status = next;
    return _session;
  }
}
