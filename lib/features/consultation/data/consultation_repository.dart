import '../../../core/network/api_client.dart';
import '../domain/models/consultation_session.dart';
import '../domain/models/consultation_status.dart';

/// The state of an appointment's consultation (the backend's
/// `/appointments/:id/consultation`). Failures surface as an `ApiException`.
abstract interface class ConsultationRepository {
  /// The consultation for an appointment, created on first request.
  Future<ConsultationSession> getSession(String appointmentId);

  /// Moves the consultation on. The backend only lets the patient's own
  /// device make some moves (checking in, waiting, reconnecting, ending);
  /// the clinician starts the call.
  Future<ConsultationSession> transition(
    String appointmentId,
    ConsultationStatus status,
  );
}

class DioConsultationRepository implements ConsultationRepository {
  DioConsultationRepository(this._client);

  final ApiClient _client;

  @override
  Future<ConsultationSession> getSession(String appointmentId) async =>
      ConsultationSession.fromJson(
        await _client.get('/appointments/$appointmentId/consultation'),
      );

  @override
  Future<ConsultationSession> transition(
    String appointmentId,
    ConsultationStatus status,
  ) async => ConsultationSession.fromJson(
    await _client.post(
      '/appointments/$appointmentId/consultation/transition',
      data: {'status': status.apiValue},
    ),
  );
}
