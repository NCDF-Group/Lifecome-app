import 'package:lifecome_mobile/features/health_records/data/health_records_repository.dart';
import 'package:lifecome_mobile/features/health_records/domain/models/clinical_note.dart';
import 'package:lifecome_mobile/features/health_records/domain/models/diagnostic_result.dart';
import 'package:lifecome_mobile/features/health_records/domain/models/prescription.dart';
import 'package:lifecome_mobile/features/health_records/domain/models/referral.dart';

/// Records a test sets up; empty by default, like the real (pending) one.
class FakeHealthRecordsRepository implements HealthRecordsRepository {
  List<ClinicalNote> noteList = [];
  List<Prescription> prescriptionList = [];
  List<Referral> referralList = [];
  List<DiagnosticResult> resultList = [];

  @override
  Future<List<ClinicalNote>> notes() async => noteList;

  @override
  Future<List<Prescription>> prescriptions() async => prescriptionList;

  @override
  Future<List<Referral>> referrals() async => referralList;

  @override
  Future<List<DiagnosticResult>> results() async => resultList;
}
