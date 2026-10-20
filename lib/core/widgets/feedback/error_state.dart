import 'package:flutter/material.dart';

import '../../network/api_exception.dart';
import '../media/lc_icons.dart';
import 'recovery_view.dart';

/// What a screen shows when its data could not be loaded (the screen pack's
/// "Service temporarily unavailable", 148): what went wrong, in plain words,
/// and a way to try again.
class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  bool get _offline =>
      error is ApiException && (error as ApiException).isNetworkError;

  /// The backend answered with a server error (5xx): ours, not theirs.
  bool get _unavailable {
    final status = error is ApiException
        ? (error as ApiException).statusCode
        : null;
    return status != null && status >= 500;
  }

  String get _message => error is ApiException
      ? (error as ApiException).message
      : 'Something went wrong. Please try again.';

  @override
  Widget build(BuildContext context) {
    final (title, message) = _offline
        ? ("You're offline", _message)
        : _unavailable
        ? (
            'Service temporarily unavailable',
            'We’re having trouble loading this right now. Your information '
                'is safe. Please try again in a moment.',
          )
        : ("We couldn't load this", _message);
    return RecoveryView(
      icon: _offline ? LcIcons.phone : LcIcons.info,
      title: title,
      message: message,
      primaryLabel: 'Try again',
      onPrimary: onRetry,
    );
  }
}
