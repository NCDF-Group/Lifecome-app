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

/// The backend has no patient records endpoints yet, so every list is empty
/// and the screens say so honestly. No sample medical records are shown.
/// Replace with an API-backed repository when the endpoints exist.
class PendingHealthRecordsRepository implements HealthRecordsRepository {
  const PendingHealthRecordsRepository();

  @override
  Future<List<ClinicalNote>> notes() async => const [];

  @override
  Future<List<Prescription>> prescriptions() async => const [];

  @override
  Future<List<Referral>> referrals() async => const [];

  @override
  Future<List<DiagnosticResult>> results() async => const [];
}
