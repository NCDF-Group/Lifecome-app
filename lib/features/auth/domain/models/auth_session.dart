/// Where the current auth attempt is in the sign-up or sign-in flow.
///
/// This mirrors the shape of the backend's own workflow states (see
/// Lifecome-backend's blueprint-derived state machines): explicit named
/// states rather than a set of booleans, so "not started" and "failed" can
/// never be confused with each other.
enum AuthStatus { initial, submitting, codeSent, verifying, verified, failed }

/// Which screen the user came from, so the verify screen can send them back
/// to the right place and use the right wording.
enum AuthFlow { signIn, createAccount }

/// The auth flow's in-memory state, held by [AuthController].
class AuthSessionState {
  const AuthSessionState({
    this.status = AuthStatus.initial,
    this.flow = AuthFlow.createAccount,
    this.fullName,
    this.dateOfBirth,
    this.needsProfile = false,
    required this.email,
    this.errorMessage,
    this.resendAvailableAt,
  });

  final AuthStatus status;
  final AuthFlow flow;
  final String? fullName;
  final DateTime? dateOfBirth;

  /// True after signing in to an account that has no profile (name + date of birth) on the
  /// backend yet, so the app asks for it before going Home.
  final bool needsProfile;
  final String email;
  final String? errorMessage;

  /// When the "resend code" action becomes available again.
  final DateTime? resendAvailableAt;

  factory AuthSessionState.empty() => const AuthSessionState(email: '');

  AuthSessionState copyWith({
    AuthStatus? status,
    AuthFlow? flow,
    String? fullName,
    DateTime? dateOfBirth,
    bool? needsProfile,
    String? email,
    String? errorMessage,
    bool clearError = false,
    DateTime? resendAvailableAt,
  }) {
    return AuthSessionState(
      status: status ?? this.status,
      flow: flow ?? this.flow,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      needsProfile: needsProfile ?? this.needsProfile,
      email: email ?? this.email,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      resendAvailableAt: resendAvailableAt ?? this.resendAvailableAt,
    );
  }
}
