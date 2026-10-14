import '../../../../core/utils/formatters.dart';
import 'consultation_status.dart';

/// The live state of one appointment's consultation
/// (`/appointments/:id/consultation`).
class ConsultationSession {
  const ConsultationSession({
    required this.id,
    required this.appointmentId,
    required this.status,
    this.startedAt,
    this.endedAt,
  });

  factory ConsultationSession.fromJson(Map<String, dynamic> json) =>
      ConsultationSession(
        id: json['id'] as String,
        appointmentId: json['appointmentId'] as String,
        status: ConsultationStatus.parse(json['status']),
        startedAt: Formatters.parseInstant(json['startedAt']),
        endedAt: Formatters.parseInstant(json['endedAt']),
      );

  final String id;
  final String appointmentId;
  final ConsultationStatus status;

  /// When the clinician first connected.
  final DateTime? startedAt;
  final DateTime? endedAt;
}
