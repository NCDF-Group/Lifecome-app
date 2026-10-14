import '../../../core/network/api_client.dart';
import '../domain/models/authorisation.dart';
import '../domain/models/eligibility_result.dart';
import '../domain/models/membership.dart';
import '../domain/models/payer.dart';

/// Health plans, memberships, cover checks and authorisations (the backend's
/// `/payers`, `/eligibility` and `/authorisations`). Failures surface as an
/// `ApiException`.
abstract interface class PayerRepository {
  /// The plans taking part, in the order they should be shown.
  Future<List<Payer>> listPayers();

  /// Checks a membership number with the plan. The [idempotencyKey] makes a
  /// retry return the same membership instead of adding a second.
  Future<Membership> verifyMembership({
    required String payerCode,
    required String memberId,
    required String idempotencyKey,
  });

  /// Asks the plan whether the membership covers a service.
  Future<EligibilityCheck> checkEligibility({
    required String membershipId,
    required String clinicalServiceCode,
  });

  /// Asks the plan to approve a booked visit.
  Future<Authorisation> requestAuthorisation({
    required String eligibilityCheckId,
    required String clinicalServiceCode,
    required String providerId,
    required String appointmentId,
    required String idempotencyKey,
  });

  Future<Authorisation> getAuthorisation(String id);
}

class DioPayerRepository implements PayerRepository {
  DioPayerRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<Payer>> listPayers() async {
    final rows = await _client.getList('/payers');
    return [
      for (final row in rows)
        if (row is Map<String, dynamic>) Payer.fromJson(row),
    ];
  }

  @override
  Future<Membership> verifyMembership({
    required String payerCode,
    required String memberId,
    required String idempotencyKey,
  }) async => Membership.fromJson(
    await _client.post(
      '/payers/verify-membership',
      data: {'payerCode': payerCode, 'memberId': memberId},
      idempotencyKey: idempotencyKey,
    ),
  );

  @override
  Future<EligibilityCheck> checkEligibility({
    required String membershipId,
    required String clinicalServiceCode,
  }) async => EligibilityCheck.fromJson(
    await _client.post(
      '/eligibility/check',
      data: {
        'membershipId': membershipId,
        'clinicalServiceCode': clinicalServiceCode,
      },
    ),
  );

  @override
  Future<Authorisation> requestAuthorisation({
    required String eligibilityCheckId,
    required String clinicalServiceCode,
    required String providerId,
    required String appointmentId,
    required String idempotencyKey,
  }) async => Authorisation.fromJson(
    await _client.post(
      '/authorisations',
      data: {
        'eligibilityCheckId': eligibilityCheckId,
        'clinicalServiceCode': clinicalServiceCode,
        'providerId': providerId,
        'appointmentId': appointmentId,
      },
      idempotencyKey: idempotencyKey,
    ),
  );

  @override
  Future<Authorisation> getAuthorisation(String id) async =>
      Authorisation.fromJson(await _client.get('/authorisations/$id'));
}
