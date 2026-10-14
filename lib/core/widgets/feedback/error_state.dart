import 'package:flutter/material.dart';

import '../../network/api_exception.dart';
import '../../theme/app_palette.dart';
import '../buttons/primary_button.dart';

/// What a screen shows when its data could not be loaded: what went wrong, in
/// plain words, and a button to try again.
class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  bool get _offline =>
      error is ApiException && (error as ApiException).isNetworkError;

  String get _message => error is ApiException
      ? (error as ApiException).message
      : 'Something went wrong. Please try again.';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: context.palette.tintRed,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _offline ? Icons.wifi_off_rounded : Icons.error_outline,
                size: 30,
                color: context.palette.danger,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _offline ? "You're offline" : "We couldn't load this",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: context.palette.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: context.palette.inkMuted,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: PrimaryButton(
                label: 'Try again',
                icon: Icons.refresh,
                onPressed: onRetry,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
