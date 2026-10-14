/// Where an appointment is in its life. The backend's `booking_status`.
enum BookingStatus {
  slotHeld('slot_held', 'Awaiting confirmation'),
  confirmed('confirmed', 'Confirmed'),
  rescheduled('rescheduled', 'Rescheduled'),
  cancelled('cancelled', 'Cancelled'),
  doctorUnavailable('doctor_unavailable', 'Clinician unavailable'),
  patientNoShow('patient_no_show', 'Missed');

  const BookingStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;

  /// The patient can still cancel it.
  bool get isCancellable => this == slotHeld || this == confirmed;

  static BookingStatus parse(Object? value) {
    for (final status in values) {
      if (status.apiValue == value) return status;
    }
    return slotHeld;
  }
}

/// How an appointment is paid for. The backend's `funding_route`.
enum FundingRoute {
  payPerVisit('pay_per_visit', 'Pay per visit'),
  lifecomeBenefits('lifecome_benefits', 'LifeCome Benefits'),
  workplace('workplace', 'Employer access'),
  membership('membership', 'Membership');

  const FundingRoute(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static FundingRoute parse(Object? value) {
    for (final route in values) {
      if (route.apiValue == value) return route;
    }
    return payPerVisit;
  }
}
