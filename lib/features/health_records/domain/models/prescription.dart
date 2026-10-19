/// A prescription issued after a clinician's review.
class Prescription {
  const Prescription({
    required this.id,
    required this.reference,
    required this.clinician,
    required this.issuedOn,
    required this.status,
    this.medicine,
    this.pharmacy,
    this.instructions,
  });

  final String id;
  final String reference;
  final String clinician;
  final DateTime issuedOn;

  /// e.g. "Issued", "Sent to pharmacy", "Dispensed".
  final String status;
  final String? medicine;
  final String? pharmacy;

  /// The clinician-authorised directions, as written.
  final String? instructions;
}
