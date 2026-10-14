import 'package:lifecome_mobile/core/network/api_exception.dart';
import 'package:lifecome_mobile/features/payer/data/payer_repository.dart';
import 'package:lifecome_mobile/features/payer/domain/models/authorisation.dart';
import 'package:lifecome_mobile/features/payer/domain/models/eligibility_result.dart';
import 'package:lifecome_mobile/features/payer/domain/models/eligibility_status.dart';
import 'package:lifecome_mobile/features/payer/domain/models/membership.dart';
import 'package:lifecome_mobile/features/payer/domain/models/payer.dart';

const testPayerBupa = Payer(
  id: 'payer-bupa',
  code: 'BUPA',
  name: 'Bupa',
  displayOrder: 1,
);

const testPayerAxa = Payer(
  id: 'payer-axa',
  code: 'AXA',
  name: 'AXA Health',
  displayOrder: 2,
);

/// A [PayerRepository] that answers from memory and records what it was asked.
/// [coverage] says what each service code comes back as; anything not listed is
/// covered.
class FakePayerRepository implements PayerRepository {
  FakePayerRepository({
    List<Payer>? payers,
    Map<String, EligibilityStatus>? coverage,
  }) : payers = payers ?? const [testPayerBupa, testPayerAxa],
       coverage = coverage ?? {};

  List<Payer> payers;
  Map<String, EligibilityStatus> coverage;
  Map<String, int> coPay = {};

  Object? listFailure;
  ApiException? verifyFailure;
  ApiException? authorisationFailure;

  /// What an authorisation request comes back as.
  AuthorisationStatus authorisationStatus = AuthorisationStatus.pending;

  final List<String> calls = [];
  String? lastPayerCode;
  String? lastMemberId;
  String? lastVerifyKey;
  String? lastAuthorisationKey;

  @override
  Future<List<Payer>> listPayers() async {
    calls.add('listPayers');
    final error = listFailure;
    if (error != null) throw error;
    return payers;
  }

  @override
  Future<Membership> verifyMembership({
    required String payerCode,
    required String memberId,
    required String idempotencyKey,
  }) async {
    calls.add('verifyMembership');
    lastPayerCode = payerCode;
    lastMemberId = memberId;
    lastVerifyKey = idempotencyKey;
    final error = verifyFailure;
    if (error != null) throw error;
    final payer = payers.firstWhere((item) => item.code == payerCode);
    return Membership(
      id: 'membership-1',
      payerId: payer.id,
      memberId: memberId,
      planId: 'Gold',
      verifiedAt: DateTime.now().toUtc(),
    );
  }

  @override
  Future<EligibilityCheck> checkEligibility({
    required String membershipId,
    required String clinicalServiceCode,
  }) async {
    calls.add('checkEligibility:$clinicalServiceCode');
    final status = coverage[clinicalServiceCode] ?? EligibilityStatus.covered;
    return EligibilityCheck(
      id: 'check-$clinicalServiceCode',
      membershipId: membershipId,
      status: status,
      coPayMinor: coPay[clinicalServiceCode],
      checkedAt: DateTime.now().toUtc(),
    );
  }

  @override
  Future<Authorisation> requestAuthorisation({
    required String eligibilityCheckId,
    required String clinicalServiceCode,
    required String providerId,
    required String appointmentId,
    required String idempotencyKey,
  }) async {
    calls.add('requestAuthorisation');
    lastAuthorisationKey = idempotencyKey;
    final error = authorisationFailure;
    if (error != null) throw error;
    return Authorisation(id: 'auth-1', status: authorisationStatus);
  }

  @override
  Future<Authorisation> getAuthorisation(String id) async {
    calls.add('getAuthorisation:$id');
    return Authorisation(id: id, status: authorisationStatus);
  }
}
