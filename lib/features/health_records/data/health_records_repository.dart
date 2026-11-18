import '../../../core/network/api_client.dart';
import '../domain/models/clinical_note.dart';
import '../domain/models/diagnostic_result.dart';
import '../domain/models/prescription.dart';
import '../domain/models/referral.dart';

/// Where the patient's records come from.
abstract interface class HealthRecordsRepository {
  Future<List<ClinicalNote>> notes();
  Future<List<Prescription>> prescriptions();
  Future<List<Referral>> referrals();
  Future<List<DiagnosticResult>> results();
}

/// Reads the signed-in patient's reviewed records from the backend.
class DioHealthRecordsRepository implements HealthRecordsRepository {
  const DioHealthRecordsRepository(this._client);

  final ApiClient _client;

  DateTime _date(Object? value) => DateTime.parse(value as String).toUtc();

  Map<String, dynamic> _map(dynamic value) =>
      value is Map<String, dynamic> ? value : const {};

  @override
  Future<List<ClinicalNote>> notes() async {
    final encounters = await _client.getList('/me/encounters');
    final details = await Future.wait([
      for (final row in encounters)
        if (row is Map<String, dynamic>)
          _client.get('/me/encounters/${row['id']}'),
    ]);
    return [
      for (final detailValue in details)
        for (final noteValue
            in _map(detailValue)['notes'] as List<dynamic>? ?? const [])
          if (noteValue is Map<String, dynamic> &&
              noteValue['status'] == 'signed')
            ClinicalNote(
              id: noteValue['id'] as String? ?? '',
              title: 'Consultation note',
              clinician:
                  _map(_map(detailValue)['encounter'])['providerName']
                      as String? ??
                  '',
              date: _date(noteValue['signedAt'] ?? noteValue['createdAt']),
              summary: noteValue['body'] as String? ?? '',
            ),
    ];
  }

  @override
  Future<List<Prescription>> prescriptions() async => [
    for (final value in await _client.getList('/me/prescriptions'))
      if (value is Map<String, dynamic>)
        Prescription(
          id: value['id'] as String? ?? '',
          reference: value['reference'] as String? ?? '',
          clinician: value['prescribedByName'] as String? ?? '',
          issuedOn: _date(value['createdAt']),
          status: value['status'] as String? ?? '',
          medicine: value['medicationName'] as String?,
          pharmacy: value['pharmacy'] as String?,
          instructions: value['instructions'] as String?,
        ),
  ];

  @override
  Future<List<Referral>> referrals() async => [
    for (final value in await _client.getList('/me/referrals'))
      if (value is Map<String, dynamic>)
        Referral(
          id: value['id'] as String? ?? '',
          reference: value['reference'] as String? ?? '',
          specialty:
              value['specialty'] as String? ??
              value['referredToDescription'] as String? ??
              '',
          status: value['status'] as String? ?? '',
          createdOn: _date(value['createdAt']),
          nextStep: value['nextStep'] as String?,
          letter: value['reason'] as String?,
        ),
  ];

  @override
  Future<List<DiagnosticResult>> results() async => [
    for (final value in await _client.getList('/me/diagnostic-results'))
      if (value is Map<String, dynamic>)
        DiagnosticResult(
          id: value['id'] as String? ?? '',
          title: value['testName'] as String? ?? '',
          reviewedBy:
              value['reviewedByName'] as String? ??
              value['originatingProviderName'] as String? ??
              '',
          date: _date(value['reviewedAt'] ?? value['receivedAt']),
          report: value['resultSummary'] as String? ?? '',
        ),
  ];
}
