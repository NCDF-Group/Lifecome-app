import '../../../../core/utils/formatters.dart';

/// The clinical profile the backend keeps for a signed-in person — their
/// `patients` row. It does not exist until they have filled in the "complete
/// your profile" step after signing up.
class PatientProfile {
  const PatientProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    this.sex,
    this.city,
    this.state,
    this.country = 'GB',
    this.avatarUpdatedAt,
  });

  factory PatientProfile.fromJson(Map<String, dynamic> json) {
    String? optional(Object? value) {
      final text = (value as String?)?.trim();
      return text == null || text.isEmpty ? null : text;
    }

    return PatientProfile(
      id: json['id'] as String,
      firstName: (json['firstName'] as String? ?? '').trim(),
      lastName: (json['lastName'] as String? ?? '').trim(),
      dateOfBirth:
          Formatters.parseDate(json['dateOfBirth']) ?? DateTime(1900, 1, 1),
      sex: optional(json['sex']),
      city: optional(json['city']),
      state: optional(json['state']),
      country: (json['country'] as String?) ?? 'GB',
      avatarUpdatedAt: Formatters.parseInstant(json['avatarUpdatedAt']),
    );
  }

  final String id;
  final String firstName;
  final String lastName;

  /// A calendar date: the time of day is always midnight and means nothing.
  final DateTime dateOfBirth;
  final String? sex;
  final String? city;

  /// The county, for a UK address.
  final String? state;

  /// ISO 3166-1 alpha-2 — `GB` or `NG`, the only two the backend accepts.
  final String country;

  /// When the profile photo was last set; null means there is no photo. It
  /// doubles as a cache-buster for the image address.
  final DateTime? avatarUpdatedAt;

  String get fullName => '$firstName $lastName'.trim();
  bool get hasAvatar => avatarUpdatedAt != null;
}

/// The values the profile form sends. Optional fields left `null` are not
/// sent at all; an empty string clears a value that was set before.
class ProfileInput {
  const ProfileInput({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    this.sex,
    this.city,
    this.state,
    this.country = 'GB',
  });

  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String? sex;
  final String? city;
  final String? state;
  final String country;

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'dateOfBirth': Formatters.isoDate(dateOfBirth),
    'sex': ?sex,
    'city': ?city,
    'state': ?state,
    'country': country,
  };
}
