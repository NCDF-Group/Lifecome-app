/// A test result shared with the patient once a clinician has reviewed it.
class DiagnosticResult {
  const DiagnosticResult({
    required this.id,
    required this.title,
    required this.reviewedBy,
    required this.date,
    required this.report,
  });

  final String id;
  final String title;
  final String reviewedBy;
  final DateTime date;

  /// The verified report and the clinician's interpretation, as written.
  final String report;
}
