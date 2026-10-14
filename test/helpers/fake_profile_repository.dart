import 'package:lifecome_mobile/core/network/api_exception.dart';
import 'package:lifecome_mobile/features/profile/data/profile_repository.dart';
import 'package:lifecome_mobile/features/profile/domain/models/me.dart';
import 'package:lifecome_mobile/features/profile/domain/models/patient_profile.dart';

/// A signed-in person for tests. Pass [withProfile] false for an account that
/// has not completed its profile yet.
Me testMe({bool withProfile = true}) => Me(
  account: const MeAccount(
    id: 'account-1',
    email: 'alex.morgan@example.com',
    phoneNumber: '+447700900123',
    status: 'active',
  ),
  profile: withProfile
      ? PatientProfile(
          id: 'patient-1',
          firstName: 'Alex',
          lastName: 'Morgan',
          dateOfBirth: DateTime(1990, 5, 20),
          sex: 'female',
          city: 'Leeds',
          state: 'West Yorkshire',
        )
      : null,
  displayName: withProfile ? 'Alex Morgan' : null,
);

/// A [ProfileRepository] that answers from memory and records what it was
/// asked. Set [failure] to make saving throw.
class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository({Me? me}) : me = me ?? testMe();

  Me me;
  Object? loadFailure;
  ApiException? failure;
  final List<String> calls = [];
  ProfileInput? lastInput;

  @override
  Future<Me> getMe() async {
    calls.add('getMe');
    final error = loadFailure;
    if (error != null) throw error;
    return me;
  }

  @override
  Future<PatientProfile> saveProfile(ProfileInput input) async {
    calls.add('saveProfile');
    return _store(input);
  }

  @override
  Future<PatientProfile> updateProfile(ProfileInput input) async {
    calls.add('updateProfile');
    return _store(input);
  }

  PatientProfile _store(ProfileInput input) {
    final error = failure;
    if (error != null) throw error;
    lastInput = input;
    final saved = PatientProfile(
      id: 'patient-1',
      firstName: input.firstName,
      lastName: input.lastName,
      dateOfBirth: input.dateOfBirth,
      sex: input.sex,
      city: input.city,
      state: input.state,
      country: input.country,
    );
    me = me.withProfile(saved);
    return saved;
  }
}
