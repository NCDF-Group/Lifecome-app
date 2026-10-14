/// What a health plan says about covering one service. The backend's
/// `eligibility_status`.
enum EligibilityStatus {
  covered('covered', 'Covered'),
  coPay('co_pay', 'Co-pay applies'),
  preAuthorisationRequired('pre_authorisation_required', 'Needs authorisation'),
  excluded('excluded', 'Not covered'),
  benefitLimitReached('benefit_limit_reached', 'Benefit limit reached'),
  payerUnavailable('payer_unavailable', "Couldn't check");

  const EligibilityStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;

  /// The service can be booked with this plan paying (possibly after a
  /// co-pay or an authorisation).
  bool get isBookable =>
      this == covered || this == coPay || this == preAuthorisationRequired;

  static EligibilityStatus parse(Object? value) {
    for (final status in values) {
      if (status.apiValue == value) return status;
    }
    return payerUnavailable;
  }
}
