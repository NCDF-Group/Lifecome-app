/// Thrown by [ApiClient] for any failed request — a non-2xx response or a network failure.
/// Carries the backend's own `error.code`/`error.message` (see Lifecome-Backend's
/// `HttpExceptionFilter`) when the server responded with one.
class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.code,
    this.statusCode,
    this.fieldErrors = const {},
  });

  /// The message for a request that never reached the server (no network,
  /// timeout). The UI checks for it to show the "you're offline" popup.
  static const networkMessage =
      'Could not connect. Check your internet connection and try again.';

  /// Raised when the saved sign-in is no longer accepted. [ApiClient] has
  /// already signed the person out by the time this is thrown.
  static const sessionExpiredCode = 'SESSION_EXPIRED';
  static const sessionExpiredMessage =
      'Your session has expired. Please sign in again.';

  final String message;
  final String? code;
  final int? statusCode;

  /// For a `VALIDATION_FAILED` response: the backend's complaint about each
  /// field, keyed by the field name it uses (`phoneNumber`, `dateOfBirth`...),
  /// so a form can show it under the right input.
  final Map<String, String> fieldErrors;

  bool get isNetworkError => message == networkMessage;
  bool get isSessionExpired => code == sessionExpiredCode;
  bool get isNotFound => statusCode == 404;

  @override
  String toString() => message;
}
