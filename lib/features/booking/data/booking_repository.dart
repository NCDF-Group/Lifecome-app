import '../../../core/network/api_client.dart';
import '../../doctors/domain/models/doctor.dart';
import '../domain/models/availability_slot.dart';
import '../domain/models/clinical_service.dart';
import '../domain/models/my_appointment.dart';

/// Services, clinicians, availability and the patient's own appointments, from the backend.
class BookingRepository {
  BookingRepository(this._client);

  final ApiClient _client;

  Future<List<ClinicalService>> listServices() async {
    final json = await _client.getList('/clinical-services');
    return [
      for (final item in json)
        ClinicalService.fromJson(item as Map<String, dynamic>),
    ];
  }

  Future<List<Doctor>> listDoctors() async {
    final json = await _client.getList('/providers');
    return [
      for (final item in json) Doctor.fromJson(item as Map<String, dynamic>),
    ];
  }

  Future<List<AvailabilitySlot>> listAvailability(String providerId) async {
    final json = await _client.getList(
      '/scheduling/providers/$providerId/availability',
    );
    final slots = [
      for (final item in json)
        AvailabilitySlot.fromJson(item as Map<String, dynamic>),
    ]..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return slots;
  }

  /// Books (holds) the slot. [idempotencyKey] makes a double tap harmless: replaying it returns the
  /// first result instead of booking twice. Returns the new appointment's id.
  Future<String> createAppointment({
    required String idempotencyKey,
    required String providerId,
    required String clinicalServiceId,
    required String availabilitySlotId,
    required String consultationMode,
    required String fundingRoute,
    String? presentingConcern,
    String? locationCity,
    String? clinicName,
    Map<String, dynamic>? intake,
  }) async {
    final json = await _client.post(
      '/appointments',
      headers: {'Idempotency-Key': idempotencyKey},
      data: {
        'providerId': providerId,
        'clinicalServiceId': clinicalServiceId,
        'availabilitySlotId': availabilitySlotId,
        'consultationMode': consultationMode,
        'fundingRoute': fundingRoute,
        if (presentingConcern != null && presentingConcern.isNotEmpty)
          'presentingConcern': presentingConcern,
        'locationCity': ?locationCity,
        'clinicName': ?clinicName,
        if (intake != null && intake.isNotEmpty) 'intake': intake,
      },
    );
    return json['id'] as String;
  }

  Future<void> confirm(
    String appointmentId, {
    required String idempotencyKey,
  }) async {
    await _client.post(
      '/appointments/$appointmentId/confirm',
      data: const {},
      headers: {'Idempotency-Key': idempotencyKey},
    );
  }

  Future<void> cancel(String appointmentId) async {
    await _client.post('/appointments/$appointmentId/cancel', data: const {});
  }

  Future<List<MyAppointment>> listMine() async {
    final json = await _client.getList('/appointments');
    return [
      for (final item in json)
        MyAppointment.fromJson(item as Map<String, dynamic>),
    ];
  }
}
