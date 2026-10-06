import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/inputs/otp_input.dart';
import '../../../core/widgets/layout/max_content_width.dart';
import '../application/auth_controller.dart';
import '../domain/models/auth_session.dart';
import 'widgets/auth_top_bar.dart';
import 'widgets/otp_timer.dart';

/// What this screen needs to know: which email the code was sent to, and
/// which flow (sign in or create account) it should return to if the user
/// taps "Change email".
class VerifyEmailArgs {
  const VerifyEmailArgs({required this.email});
  final String email;
}

/// Masks all but the first and last character of the email's local part,
/// e.g. "example@gmail.com" -> "e***e@gmail.com".
String _maskEmail(String email) {
  final atIndex = email.indexOf('@');
  if (atIndex <= 1) return email;
  final local = email.substring(0, atIndex);
  final domain = email.substring(atIndex);
  return '${local[0]}***${local[local.length - 1]}$domain';
}

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key, required this.args});

  final VerifyEmailArgs args;

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final _otpKey = GlobalKey<OtpInputState>();
  String _code = '';

  Future<void> _submit([String? completedCode]) async {
    final code = completedCode ?? _code;
    if (code.length != 6) return;

    final verified = await ref
        .read(authControllerProvider.notifier)
        .verifyCode(code);
    if (!mounted) return;

    if (verified) {
      context.go(RoutePaths.createPassword);
    } else {
      _otpKey.currentState?.clear();
      setState(() => _code = '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final verifying = authState.status == AuthStatus.verifying;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: MaxContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AuthTopBar(),
                const SizedBox(height: AppSpacing.xl),
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.blue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mark_email_read_outlined,
                      color: AppColors.blue,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Verify your email address',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'We sent a 6 digit code to ${_maskEmail(widget.args.email)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.inkMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                OtpInput(
                  key: _otpKey,
                  onCompleted: (code) => _submit(code),
                  onChanged: (value) => setState(() => _code = value),
                  errorText: authState.errorMessage,
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: 'Verify',
                  loading: verifying,
                  onPressed: _code.length == 6 ? () => _submit() : null,
                ),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: authState.resendAvailableAt != null
                      ? OtpTimer(
                          availableAt: authState.resendAvailableAt!,
                          onResend: () => ref
                              .read(authControllerProvider.notifier)
                              .resendCode(),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
