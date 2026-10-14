import '../../../core/network/api_client.dart';
import '../../payment/domain/models/payment_transaction.dart';
import '../domain/models/appointment.dart';
import '../domain/models/availability_slot.dart';
import '../domain/models/clinical_service.dart';

/// Services, availability, appointments and payments (the backend's
/// `/clinical-services`, `/scheduling`, `/appointments` and `/payments`).
/// Failures surface as an `ApiException`.
abstract interface class BookingRepository {
  Future<List<ClinicalService>> listServices();

  /// Times a clinician can still be booked, soonest first.
  Future<List<AvailabilitySlot>> listAvailability(String providerId);

  Future<List<Appointment>> listAppointments();

  /// Creates a held appointment (which also holds its time for ten minutes).
  /// The [idempotencyKey] makes a retry return the same appointment instead of
  /// booking twice. The clinician and service names and the time are what the
  /// patient chose, used to fill in what the create reply leaves out.
  Future<Appointment> createAppointment(
    NewAppointment request, {
    required String idempotencyKey,
    required String providerName,
    required String serviceName,
    required AvailabilitySlot slot,
  });

  /// Confirms a held appointment. The backend only allows this in test
  /// environments; otherwise it is confirmed once payment or authorisation
  /// completes and this throws `PAYMENT_REQUIRED`.
  Future<Appointment> confirmAppointment(
    Appointment appointment, {
    required String idempotencyKey,
  });

  Future<Appointment> cancelAppointment(Appointment appointment);

  Future<PaymentTransaction> createPaymentIntent({
    required Appointment appointment,
    required String idempotencyKey,
  });
}

class DioBookingRepository implements BookingRepository {
  DioBookingRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<ClinicalService>> listServices() async {
    final rows = await _client.getList('/clinical-services');
    return [
      for (final row in rows)
        if (row is Map<String, dynamic>) ClinicalService.fromJson(row),
    ];
  }

  @override
  Future<List<AvailabilitySlot>> listAvailability(String providerId) async {
    final rows = await _client.getList(
      '/scheduling/providers/$providerId/availability',
    );
    final slots = [
      for (final row in rows)
        if (row is Map<String, dynamic>) AvailabilitySlot.fromJson(row),
    ]..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return slots;
  }

  @override
  Future<List<Appointment>> listAppointments() async {
    final rows = await _client.getList('/appointments');
    return [
      for (final row in rows)
        if (row is Map<String, dynamic>) Appointment.fromJson(row),
    ];
  }

  @override
  Future<Appointment> createAppointment(
    NewAppointment request, {
    required String idempotencyKey,
    required String providerName,
    required String serviceName,
    required AvailabilitySlot slot,
  }) async {
    final json = await _client.post(
      '/appointments',
      data: request.toJson(),
      idempotencyKey: idempotencyKey,
    );
    return Appointment.fromJson(
      json,
      providerName: providerName,
      serviceName: serviceName,
      startsAt: slot.startsAt,
      durationMinutes: slot.durationMinutes,
    );
  }

  @override
  Future<Appointment> confirmAppointment(
    Appointment appointment, {
    required String idempotencyKey,
  }) async {
    final json = await _client.post(
      '/appointments/${appointment.id}/confirm',
      idempotencyKey: idempotencyKey,
    );
    return _withNamesOf(appointment, json);
  }

  @override
  Future<Appointment> cancelAppointment(Appointment appointment) async {
    final json = await _client.post('/appointments/${appointment.id}/cancel');
    return _withNamesOf(appointment, json);
  }

  @override
  Future<PaymentTransaction> createPaymentIntent({
    required Appointment appointment,
    required String idempotencyKey,
  }) async {
    final json = await _client.post(
      '/payments/intents',
      data: {
        'appointmentId': appointment.id,
        'clinicalServiceId': appointment.clinicalServiceId,
        'idempotencyKey': idempotencyKey,
      },
      idempotencyKey: idempotencyKey,
    );
    return PaymentTransaction.fromJson(json);
  }

  /// A confirm or cancel reply is the bare appointment row; keep the names and
  /// time the screen already has.
  Appointment _withNamesOf(Appointment known, Map<String, dynamic> json) {
    return Appointment.fromJson(
      json,
      providerName: known.providerName,
      serviceName: known.serviceName,
      startsAt: known.startsAt,
      durationMinutes: known.durationMinutes,
    );
  }
}
