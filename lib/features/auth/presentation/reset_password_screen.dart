import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/buttons/tinted_button.dart';
import '../../../core/widgets/inputs/otp_input.dart';
import '../../../core/widgets/layout/max_content_width.dart';
import '../data/auth_repository.dart';
import 'new_password_screen.dart';
import 'widgets/otp_timer.dart';
import '../../../core/widgets/feedback/app_popup.dart';

/// What this screen needs to know: which email the reset code was sent to.
class ResetPasswordArgs {
  const ResetPasswordArgs({required this.email});
  final String email;
}

/// Step 2 of the forgot-password flow: enter the reset code sent by email.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, required this.args});

  final ResetPasswordArgs args;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _otpKey = GlobalKey<OtpInputState>();
  String _code = '';
  String? _errorText;
  bool _loading = false;
  DateTime _resendAvailableAt = DateTime.now().add(const Duration(seconds: 30));

  Future<void> _submit([String? completedCode]) async {
    final code = completedCode ?? _code;
    if (code.length != 6) return;

    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      await ref
          .read(authRepositoryProvider)
          .verifyPasswordResetCode(email: widget.args.email, code: code);
      if (!mounted) return;
      context.push(
        RoutePaths.newPassword,
        extra: NewPasswordArgs(email: widget.args.email, code: code),
      );
    } on AuthException catch (error) {
      setState(() => _errorText = error.message);
      _otpKey.currentState?.clear();
      setState(() => _code = '');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    try {
      await ref
          .read(authRepositoryProvider)
          .requestPasswordReset(email: widget.args.email);
      setState(
        () => _resendAvailableAt = DateTime.now().add(
          const Duration(seconds: 30),
        ),
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      showErrorPopup(context, error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: MaxContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SvgPicture.asset(
                      'assets/images/logo/lifecome-live-logo.svg',
                      height: 24,
                      semanticsLabel: 'LifeCome Live',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
                const Text(
                  'Enter reset code',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.inkMuted,
                      height: 1.4,
                    ),
                    children: [
                      const TextSpan(text: 'Enter the 6-digit code sent to\n'),
                      TextSpan(
                        text: widget.args.email,
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                OtpInput(
                  key: _otpKey,
                  onCompleted: (code) => _submit(code),
                  onChanged: (value) => setState(() => _code = value),
                  errorText: _errorText,
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: 'Verify code',
                  icon: Icons.arrow_forward,
                  loading: _loading,
                  onPressed: _code.length == 6 ? () => _submit() : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                TintedButton(
                  label: 'Change email',
                  onPressed: () => context.pop(),
                ),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: OtpTimer(
                    availableAt: _resendAvailableAt,
                    onResend: _resend,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
