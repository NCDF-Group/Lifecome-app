import '../../../booking/domain/models/consultation_mode.dart';

/// A clinician from the backend's provider directory (`/providers`).
///
/// The directory holds only what is listed here. A photo, biography,
/// qualifications, years of experience and ratings are not stored, so none
/// are shown: a person's avatar is their initials.
class Doctor {
  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.languages,
    required this.modes,
    this.city,
    this.state,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    String? optional(Object? value) {
      final text = (value as String?)?.trim();
      return text == null || text.isEmpty ? null : text;
    }

    return Doctor(
      id: json['id'] as String,
      name: (json['displayName'] as String? ?? '').trim(),
      specialty: (json['specialty'] as String? ?? '').trim(),
      languages: [
        for (final item in (json['languages'] as List<dynamic>? ?? const []))
          if (item is String && item.trim().isNotEmpty) item.trim(),
      ],
      modes: {
        for (final item
            in (json['consultationModes'] as List<dynamic>? ?? const []))
          ?ConsultationMode.parse(item),
      },
      city: optional(json['city']),
      state: optional(json['state']),
    );
  }

  final String id;
  final String name;
  final String specialty;
  final List<String> languages;

  /// The kinds of appointment this clinician offers.
  final Set<ConsultationMode> modes;

  /// Where their clinic is, if they have one.
  final String? city;
  final String? state;

  bool offers(ConsultationMode mode) => modes.contains(mode);

  /// `Leeds, West Yorkshire`, or null for a clinician with no clinic.
  String? get locationLabel {
    final parts = [?city, ?state];
    return parts.isEmpty ? null : parts.join(', ');
  }
}
