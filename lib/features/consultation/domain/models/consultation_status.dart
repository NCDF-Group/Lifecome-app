/// Where a consultation is, from check-in to the end. The backend's
/// `consultation_status`.
enum ConsultationStatus {
  booked('booked'),
  checkInOpen('check_in_open'),
  deviceCheck('device_check'),
  waiting('waiting'),
  clinicianJoining('clinician_joining'),
  connected('connected'),
  reconnecting('reconnecting'),
  audioFallback('audio_fallback'),
  ended('ended');

  const ConsultationStatus(this.apiValue);

  final String apiValue;

  /// The patient has not yet told the clinician they are here.
  bool get isBeforeWaiting =>
      this == booked || this == checkInOpen || this == deviceCheck;

  /// The clinician has started the appointment and it has not finished.
  bool get isLive =>
      this == clinicianJoining ||
      this == connected ||
      this == reconnecting ||
      this == audioFallback;

  static ConsultationStatus parse(Object? value) {
    for (final status in values) {
      if (status.apiValue == value) return status;
    }
    return booked;
  }
}
