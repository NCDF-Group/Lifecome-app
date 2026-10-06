/// Thrown by [ApiClient] for any failed request — a non-2xx response or a network failure.
/// Carries the backend's own `error.code`/`error.message` (see Lifecome-Backen's
/// `HttpExceptionFilter`) when the server responded with one.
class ApiException implements Exception {
  const ApiException(this.message, {this.code, this.statusCode});

  /// The message for a request that never reached the server (no network,
  /// timeout). The UI checks for it to show the "you're offline" popup.
  static const networkMessage =
      'Could not connect. Check your internet connection and try again.';

  final String message;
  final String? code;
  final int? statusCode;

  @override
  String toString() => message;
}
