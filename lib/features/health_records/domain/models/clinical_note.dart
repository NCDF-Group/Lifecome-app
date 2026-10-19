/// A consultation record: the clinician's written summary of one visit.
class ClinicalNote {
  const ClinicalNote({
    required this.id,
    required this.title,
    required this.clinician,
    required this.date,
    required this.summary,
  });

  final String id;

  /// e.g. "GP consultation summary".
  final String title;
  final String clinician;
  final DateTime date;

  /// The clinician's reviewed text, shown as written.
  final String summary;
}
