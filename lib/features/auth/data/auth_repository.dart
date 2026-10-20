import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';

/// What a successful sign-in (or sign-up verification) gives back: the access
/// token for the backend and who the account belongs to.
class SignedInAccount {
  const SignedInAccount({
    required this.accessToken,
    required this.userAccountId,
    required this.email,
    this.firstName,
    this.lastName,
  });

  factory SignedInAccount.fromJson(Map<String, dynamic> json) {
    final account = json['account'] as Map<String, dynamic>;
    return SignedInAccount(
      accessToken: json['accessToken'] as String,
      userAccountId: account['id'] as String,
      email: account['email'] as String,
      firstName: account['firstName'] as String?,
      lastName: account['lastName'] as String?,
    );
  }

  final String accessToken;
  final String userAccountId;
  final String email;
  final String? firstName;
  final String? lastName;
}

/// Talks to the backend's identity endpoints (see Lifecome-Backend's
/// `IdentityModule`). Kept as an interface so the UI and controller never
/// depend on how a request is actually made.
abstract interface class AuthRepository {
  /// Signs in with an email and password. Throws an [AuthException] if the
  /// credentials are wrong.
  Future<SignedInAccount> signInWithPassword({
    required String email,
    required String password,
  });

  /// Registers with name, email, phone number and password all at once, and
  /// sends the first verification code to the email address. Returns the
  /// id of the account the code was sent for.
  Future<String> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
  });

  /// Verifies the 6-digit code sent to [email]. The password
  /// was already set at [register], so a successful verify signs the
  /// account straight in — throws an [AuthException] if the code is wrong,
  /// expired, or has been tried too many times.
  Future<SignedInAccount> verifyEmailCode({
    required String email,
    required String code,
  });

  /// Requests a new code for an account that already has one pending.
  Future<void> resendEmailCode({required String email});

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
  const AuthException(this.message, {this.code, this.fieldErrors = const {}});

  factory AuthException.from(ApiException error) => AuthException(
    error.message,
    code: error.code,
    fieldErrors: error.fieldErrors,
  );

  final String message;

  /// The backend's machine-readable code (`OTP_INCORRECT`, `INVALID_CREDENTIALS`...).
  final String? code;

  /// Per-field complaints from the backend's own validation.
  final Map<String, String> fieldErrors;

  @override
  String toString() => message;
}

/// Talks to the real backend (see Lifecome-Backend's `IdentityModule`).
class DioAuthRepository implements AuthRepository {
  DioAuthRepository(this._client);

  final ApiClient _client;

  /// The identity endpoints key everything past registration off `userAccountId`, not
  /// email — but this repository's own interface only carries email past [register].
  /// Caches the id that call returns; [_accountIdFor] throws if the app restarted
  /// mid-flow and the cache is empty, since re-registering needs the full form again.
  final Map<String, String> _accountIdByEmail = {};

  @override
  Future<SignedInAccount> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        '/identity/login',
        data: {'email': email, 'password': password},
        authenticated: false,
      );
      return SignedInAccount.fromJson(response);
    } on ApiException catch (error) {
      throw AuthException.from(error);
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
        authenticated: false,
      );
      // The backend answers a known email with the existing account rather than
      // an error. An active one means this person already signed up.
      if (response['status'] == 'active') {
        throw const AuthException(
          'An account with this email already exists. Sign in instead.',
          code: 'ACCOUNT_EXISTS',
        );
      }
      final id = response['id'] as String;
      _accountIdByEmail[email] = id;
      return id;
    } on ApiException catch (error) {
      throw AuthException.from(error);
    }
  }

  @override
  Future<SignedInAccount> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    try {
      final accountId = await _accountIdFor(email);
      final response = await _client.post(
        '/identity/otp/verify',
        data: {'userAccountId': accountId, 'code': code},
        authenticated: false,
      );
      return SignedInAccount.fromJson(response);
    } on ApiException catch (error) {
      throw AuthException.from(error);
    }
  }

  @override
  Future<void> resendEmailCode({required String email}) async {
    try {
      final accountId = await _accountIdFor(email);
      await _client.post(
        '/identity/otp/request',
        data: {'userAccountId': accountId},
        authenticated: false,
      );
    } on ApiException catch (error) {
      throw AuthException.from(error);
    }
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    try {
      await _client.post(
        '/identity/password-reset/request',
        data: {'email': email},
        authenticated: false,
      );
    } on ApiException catch (error) {
      throw AuthException.from(error);
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
        authenticated: false,
      );
    } on ApiException catch (error) {
      throw AuthException.from(error);
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
        authenticated: false,
      );
    } on ApiException catch (error) {
      throw AuthException.from(error);
    }
  }

  Future<String> _accountIdFor(String email) async {
    final cached = _accountIdByEmail[email];
    if (cached != null) return cached;
    throw const AuthException('Your session expired. Please start again.');
  }
}
