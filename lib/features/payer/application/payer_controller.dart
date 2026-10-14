import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../booking/application/booking_controller.dart';
import '../../booking/domain/models/clinical_service.dart';
import '../data/payer_repository.dart';
import '../domain/models/eligibility_result.dart';
import '../domain/models/membership.dart';
import '../domain/models/payer.dart';

/// The payer repository the screens depend on. Overridden in tests.
final payerRepositoryProvider = Provider<PayerRepository>((ref) {
  return DioPayerRepository(ref.watch(apiClientProvider));
});

/// The health plans taking part, in the order the backend lists them.
final payersProvider = FutureProvider<List<Payer>>((ref) {
  ref.watch(sessionEpochProvider);
  return ref.watch(payerRepositoryProvider).listPayers();
});

/// The memberships the person has verified during this sign-in. The backend
/// has no way to list a person's memberships, so this is only what they have
/// verified since signing in; it starts empty for the next person.
class LinkedPlansNotifier extends Notifier<List<LinkedPlan>> {
  @override
  List<LinkedPlan> build() {
    ref.watch(sessionEpochProvider);
    return const [];
  }

  void add(LinkedPlan plan) {
    state = [
      for (final existing in state)
        if (existing.membership.id != plan.membership.id) existing,
      plan,
    ];
  }
}

final linkedPlansProvider =
    NotifierProvider<LinkedPlansNotifier, List<LinkedPlan>>(
      LinkedPlansNotifier.new,
    );

/// What a plan says about one service: its answer, or why there is none.
class ServiceCoverage {
  const ServiceCoverage({required this.service, this.check, this.error});

  final ClinicalService service;
  final EligibilityCheck? check;
  final Object? error;
}

/// What a membership covers: the plan is asked about every bookable service.
/// One service failing to answer does not hide the others.
final serviceCoverageProvider =
    FutureProvider.family<List<ServiceCoverage>, String>((
      ref,
      membershipId,
    ) async {
      ref.watch(sessionEpochProvider);
      final services = await ref.watch(clinicalServicesProvider.future);
      final repository = ref.watch(payerRepositoryProvider);
      return Future.wait([
        for (final service in services)
          () async {
            try {
              return ServiceCoverage(
                service: service,
                check: await repository.checkEligibility(
                  membershipId: membershipId,
                  clinicalServiceCode: service.code,
                ),
              );
            } catch (error) {
              return ServiceCoverage(service: service, error: error);
            }
          }(),
      ]);
    });

/// Verifies a membership number with its plan and remembers the result.
class PayerController {
  PayerController(this._ref);

  final Ref _ref;

  /// Throws an `ApiException` when the plan cannot verify the membership.
  Future<LinkedPlan> verify({
    required Payer payer,
    required String memberId,
    required String idempotencyKey,
  }) async {
    final membership = await _ref
        .read(payerRepositoryProvider)
        .verifyMembership(
          payerCode: payer.code,
          memberId: memberId,
          idempotencyKey: idempotencyKey,
        );
    final plan = LinkedPlan(payer: payer, membership: membership);
    _ref.read(linkedPlansProvider.notifier).add(plan);
    return plan;
  }
}

final payerControllerProvider = Provider<PayerController>(PayerController.new);
