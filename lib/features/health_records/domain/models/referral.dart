/// A referral to another service, and who arranges what next.
class Referral {
  const Referral({
    required this.id,
    required this.reference,
    required this.specialty,
    required this.status,
    required this.createdOn,
    this.nextStep,
    this.letter,
  });

  final String id;
  final String reference;
  final String specialty;

  /// e.g. "Awaiting arrangement", "Appointment booked".
  final String status;
  final DateTime createdOn;
  final String? nextStep;

  /// The clinician's referral letter, as written.
  final String? letter;
}
