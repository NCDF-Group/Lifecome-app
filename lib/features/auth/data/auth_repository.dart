import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';

/// Talks to the backend's identity endpoints (see Lifecome-backend's
/// `IdentityModule`). Kept as an interface so the UI and controller never
/// depend on how a request is actually made.
abstract interface class AuthRepository {
  /// Signs in with an email and password. Throws an [AuthException] if the
  /// credentials are wrong.
  Future<void> signInWithPassword({
    required String email,
    required String password,
  });

  /// Registers with name, email, phone number and password all at once, and
  /// sends the first verification code by SMS to [phoneNumber]. Returns the
  /// id of the account the code was sent for.
  Future<String> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
  });

  /// Verifies the 6-digit code sent to [email]'s phone number. The password
  /// was already set at [register], so a successful verify signs the
  /// account straight in — throws an [AuthException] if the code is wrong,
  /// expired, or has been tried too many times.
  Future<void> verifyPhoneCode({required String email, required String code});

  /// Requests a new code for an account that already has one pending.
  Future<void> resendPhoneCode({required String email});

  /// Step 1 of the forgot-password flow: sends a reset code to [email] if
  /// an account exists for it. Never reveals whether the account exists.
  Future<void> requestPasswordReset({required String email});

  /// Step 2: verifies the reset code sent to [email]. Throws an
  /// [AuthException] if the code is wrong or expired.
  Future<void> verifyPasswordResetCode({
    required String email,
    required String code,
  });

  /// Step 3: sets a new password once the reset code has been verified.
  Future<void> setNewPassword({
    required String email,
    required String code,
    required String newPassword,
  });
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// A fake, in-memory implementation used until the backend's identity
/// endpoints are wired in through `core/network`. Accepts the fixed
/// password "password123" for sign in, and the fixed code 123456 for both
/// email verification and password reset, so the flow can be built and
/// demonstrated without a live server. Swap this for a real Dio-backed
/// implementation without changing anything in `application/` or
/// `presentation/`.
class FakeAuthRepository implements AuthRepository {
  static const _demoPassword = 'password123';
  static const _demoCode = '123456';

  @override
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (password != _demoPassword) {
      throw const AuthException(
        'Incorrect email or password. Use password123 in this demo build.',
      );
    }
  }

  @override
  Future<String> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (password.length < 8) {
      throw const AuthException('Your password must be at least 8 characters.');
    }
    return 'demo-account-id';
  }

  @override
  Future<void> verifyPhoneCode({
    required String email,
    required String code,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (code != _demoCode) {
      throw const AuthException(
        'That code is not correct. Use 123456 in this demo build.',
      );
    }
  }

  @override
  Future<void> resendPhoneCode({required String email}) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
  }

  @override
  Future<void> verifyPasswordResetCode({
    required String email,
    required String code,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (code != _demoCode) {
      throw const AuthException(
        'That code is not correct. Use 123456 in this demo build.',
      );
    }
  }

  @override
  Future<void> setNewPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (newPassword.length < 8) {
      throw const AuthException(
        'Your new password must be at least 8 characters.',
      );
    }
  }
}

/// Talks to the real backend (see Lifecome-Backen's `IdentityModule`). Replaces
/// [FakeAuthRepository] in `core/providers/core_providers.dart`.
class DioAuthRepository implements AuthRepository {
  DioAuthRepository(this._client);

  final ApiClient _client;

  /// The identity endpoints key everything past registration off `userAccountId`, not
  /// email — but this repository's own interface only carries email past [register].
  /// Caches the id that call returns; [_accountIdFor] throws if the app restarted
  /// mid-flow and the cache is empty, since re-registering needs the full form again.
  final Map<String, String> _accountIdByEmail = {};

  @override
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        '/identity/login',
        data: {'email': email, 'password': password},
      );
      _client.accessToken = response['accessToken'] as String?;
    } on ApiException catch (error) {
      throw AuthException(error.message);
    }
  }

  @override
  Future<String> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        '/identity/register',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phoneNumber': phoneNumber,
          'password': password,
        },
      );
      final id = response['id'] as String;
      _accountIdByEmail[email] = id;
      return id;
    } on ApiException catch (error) {
      throw AuthException(error.message);
    }
  }

  @override
  Future<void> verifyPhoneCode({
    required String email,
    required String code,
  }) async {
    try {
      final accountId = await _accountIdFor(email);
      final response = await _client.post(
        '/identity/otp/verify',
        data: {'userAccountId': accountId, 'code': code},
      );
      _client.accessToken = response['accessToken'] as String?;
    } on ApiException catch (error) {
      throw AuthException(error.message);
    }
  }

  @override
  Future<void> resendPhoneCode({required String email}) async {
    try {
      final accountId = await _accountIdFor(email);
      await _client.post(
        '/identity/otp/request',
        data: {'userAccountId': accountId},
      );
    } on ApiException catch (error) {
      throw AuthException(error.message);
    }
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    try {
      await _client.post(
        '/identity/password-reset/request',
        data: {'email': email},
      );
    } on ApiException catch (error) {
      throw AuthException(error.message);
    }
  }

  @override
  Future<void> verifyPasswordResetCode({
    required String email,
    required String code,
  }) async {
    try {
      await _client.post(
        '/identity/password-reset/verify',
        data: {'email': email, 'code': code},
      );
    } on ApiException catch (error) {
      throw AuthException(error.message);
    }
  }

  @override
  Future<void> setNewPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      await _client.post(
        '/identity/password-reset/confirm',
        data: {'email': email, 'code': code, 'newPassword': newPassword},
      );
    } on ApiException catch (error) {
      throw AuthException(error.message);
    }
  }

  Future<String> _accountIdFor(String email) async {
    final cached = _accountIdByEmail[email];
    if (cached != null) return cached;
    throw const AuthException('Your session expired. Please start again.');
  }
}
