import 'patient_profile.dart';

/// The sign-in account behind a profile: how the person logs in and is reached.
class MeAccount {
  const MeAccount({
    required this.id,
    required this.email,
    required this.status,
    this.phoneNumber,
  });

  factory MeAccount.fromJson(Map<String, dynamic> json) => MeAccount(
    id: json['id'] as String,
    email: json['email'] as String,
    phoneNumber: json['phoneNumber'] as String?,
    status: json['status'] as String? ?? 'active',
  );

  final String id;
  final String email;
  final String? phoneNumber;
  final String status;
}

/// What `GET /me` returns: the account, plus the clinical profile once there
/// is one.
class Me {
  const Me({required this.account, this.profile, this.displayName});

  factory Me.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'];
    return Me(
      account: MeAccount.fromJson(json['account'] as Map<String, dynamic>),
      profile: profile is Map<String, dynamic>
          ? PatientProfile.fromJson(profile)
          : null,
      displayName: json['displayName'] as String?,
    );
  }

  final MeAccount account;

  /// Null until the person has completed their profile.
  final PatientProfile? profile;
  final String? displayName;

  bool get needsProfile => profile == null;

  Me withProfile(PatientProfile updated) => Me(
    account: account,
    profile: updated,
    displayName: updated.fullName.isEmpty ? displayName : updated.fullName,
  );
}
