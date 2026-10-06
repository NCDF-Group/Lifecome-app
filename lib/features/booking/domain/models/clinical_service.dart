/// A bookable service (blueprint view 10, Choose a Service). `coveredByHmo`
/// only applies when booking through an HMO — see `CheckEligibilityScreen`;
/// for a direct-pay booking, `fee` is what the patient is shown instead.
class ClinicalService {
  const ClinicalService({
    required this.id,
    required this.title,
    required this.description,
    required this.fee,
    this.requiresAuthorisation = false,
  });

  final String id;
  final String title;
  final String description;
  final int fee;
  final bool requiresAuthorisation;
}

const clinicalServices = [
  ClinicalService(
    id: 'gp-consultation',
    title: 'GP Consultation',
    description: 'Talk through a new health concern.',
    fee: 6000,
  ),
  ClinicalService(
    id: 'follow-up',
    title: 'Follow-up Visit',
    description: 'Review progress with your doctor.',
    fee: 4000,
  ),
  ClinicalService(
    id: 'results-review',
    title: 'Results Review',
    description: 'Discuss your test results.',
    fee: 4000,
  ),
  ClinicalService(
    id: 'referral-advice',
    title: 'Referral Advice',
    description: 'Plan your next step in care.',
    fee: 5000,
    requiresAuthorisation: true,
  ),
];
