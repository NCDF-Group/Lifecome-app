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

  /// Registers by email and triggers a verification code. The account has
  /// no password yet at this point — [completeSignUp] sets one once the
  /// code is verified. Returns the id of the account the code was sent for.
  Future<String> requestEmailCode({
    required String email,
    String? fullName,
    String? referralCode,
    String? phoneNumber,
    DateTime? dateOfBirth,
  });

  /// Verifies a 6-digit code sent to [email]. Throws an [AuthException] if
  /// the code is wrong, expired, or has been tried too many times.
  Future<void> verifyEmailCode({required String email, required String code});

  /// Requests a new code for an email that already has one pending.
  Future<void> resendEmailCode({required String email});

  /// Sets the new account's password once its email is verified, finishing
  /// sign-up. Throws an [AuthException] if the password doesn't meet the
  /// account's password rules.
  Future<void> completeSignUp({
    required String email,
    required String password,
  });

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
  Future<String> requestEmailCode({
    required String email,
    String? fullName,
    String? referralCode,
    String? phoneNumber,
    DateTime? dateOfBirth,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return 'demo-account-id';
  }

  @override
  Future<void> verifyEmailCode({
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
  Future<void> resendEmailCode({required String email}) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> completeSignUp({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (password.length < 8) {
      throw const AuthException('Your password must be at least 8 characters.');
    }
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
  /// email — but this repository's own interface only carries email past
  /// [requestEmailCode]. Caches the id that call returns; [_accountIdFor] falls back to
  /// `register`'s idempotent lookup (an already-registered email never re-triggers an OTP
  /// send — see `IdentityService.register`) if the app restarted mid-flow and the cache is
  /// empty.
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
  Future<String> requestEmailCode({
    required String email,
    String? fullName,
    String? referralCode,
    String? phoneNumber,
    DateTime? dateOfBirth,
  }) async {
    // fullName/referralCode/dateOfBirth aren't accepted by this endpoint yet (see
    // Lifecome-Backen's `RegisterDto`) — they belong to a patient-profile step that doesn't
    // exist on the backend yet, so they're collected here but not sent anywhere.
    try {
      final response = await _client.post(
        '/identity/register',
        data: {
          'email': email,
          if (phoneNumber != null && phoneNumber.isNotEmpty)
            'phoneNumber': phoneNumber,
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
  Future<void> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    try {
      final accountId = await _accountIdFor(email);
      await _client.post(
        '/identity/otp/verify',
        data: {'userAccountId': accountId, 'code': code},
      );
    } on ApiException catch (error) {
      throw AuthException(error.message);
    }
  }

  @override
  Future<void> resendEmailCode({required String email}) async {
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
  Future<void> completeSignUp({
    required String email,
    required String password,
  }) async {
    try {
      final accountId = await _accountIdFor(email);
      final response = await _client.post(
        '/identity/password',
        data: {'userAccountId': accountId, 'password': password},
      );
      _client.accessToken = response['accessToken'] as String?;
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
    return requestEmailCode(email: email);
  }
}
