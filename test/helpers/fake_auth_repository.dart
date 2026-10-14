import 'package:lifecome_mobile/features/auth/data/auth_repository.dart';

/// An [AuthRepository] that records what it was asked and never touches the
/// network. Set [failure] to make every call throw it.
class FakeAuthRepository implements AuthRepository {
  final List<String> calls = [];
  AuthException? failure;

  void _record(String call) {
    calls.add(call);
    final error = failure;
    if (error != null) throw error;
  }

  @override
  Future<SignedInAccount> signInWithPassword({
    required String email,
    required String password,
  }) async {
    _record('signIn:$email');
    return SignedInAccount(
      accessToken: 'token',
      userAccountId: 'account-1',
      email: email,
      firstName: 'Alex',
      lastName: 'Morgan',
    );
  }

  @override
  Future<String> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    _record('register:$firstName $lastName:$email:$phoneNumber');
    return 'account-1';
  }

  @override
  Future<SignedInAccount> verifyPhoneCode({
    required String email,
    required String code,
  }) async {
    _record('verifyPhoneCode:$email:$code');
    return SignedInAccount(
      accessToken: 'token',
      userAccountId: 'account-1',
      email: email,
      firstName: 'Alex',
      lastName: 'Morgan',
    );
  }

  @override
  Future<void> resendPhoneCode({required String email}) async {
    _record('resendPhoneCode:$email');
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    _record('requestPasswordReset:$email');
  }

  @override
  Future<void> verifyPasswordResetCode({
    required String email,
    required String code,
  }) async {
    _record('verifyPasswordResetCode:$email:$code');
  }

  @override
  Future<void> setNewPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    _record('setNewPassword:$email:$code');
  }
}
