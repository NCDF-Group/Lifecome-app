/// A clinician in the LifeCome network, as the backend's provider directory describes them.
/// (The directory has no ratings, qualifications or bio, so the app doesn't invent any.)
class Doctor {
  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.languages,
    required this.modes,
    this.city,
  });

  final String id;
  final String name;
  final String specialty;
  final List<String> languages;

  /// Which kinds of appointment they offer: `video`, `audio`, `in_person`.
  final List<String> modes;
  final String? city;

  bool get offersInPerson => modes.contains('in_person');
  bool get offersOnline => modes.contains('video') || modes.contains('audio');

  factory Doctor.fromJson(Map<String, dynamic> json) => Doctor(
    id: json['id'] as String,
    name: json['displayName'] as String,
    specialty: json['specialty'] as String,
    languages: (json['languages'] as List<dynamic>? ?? const []).cast<String>(),
    modes: (json['consultationModes'] as List<dynamic>? ?? const [])
        .cast<String>(),
    city: json['city'] as String?,
  );
}
