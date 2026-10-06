/// The signed-in patient's clinical profile, as returned by the backend's `GET /me`.
class PatientProfile {
  const PatientProfile({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    this.country = 'NG',
    this.avatarUpdatedAt,
  });

  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String country;

  /// Set when the patient has a profile photo; also used to bust the image cache.
  final DateTime? avatarUpdatedAt;

  String get fullName => '$firstName $lastName'.trim();

  factory PatientProfile.fromJson(Map<String, dynamic> json) => PatientProfile(
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String,
    dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
    country: (json['country'] as String?) ?? 'NG',
    avatarUpdatedAt: json['avatarUpdatedAt'] == null
        ? null
        : DateTime.parse(json['avatarUpdatedAt'] as String),
  );
}

/// `GET /me`: the sign-in account plus the profile (null until it has been created).
class MyAccount {
  const MyAccount({required this.email, this.phoneNumber, this.profile});

  final String email;
  final String? phoneNumber;
  final PatientProfile? profile;

  /// What to greet the user with - never the email.
  String? get firstName => profile?.firstName;

  factory MyAccount.fromJson(Map<String, dynamic> json) {
    final account = json['account'] as Map<String, dynamic>;
    final profile = json['profile'] as Map<String, dynamic>?;
    return MyAccount(
      email: account['email'] as String,
      phoneNumber: account['phoneNumber'] as String?,
      profile: profile == null ? null : PatientProfile.fromJson(profile),
    );
  }
}
