import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/animation/fade_in.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/inputs/otp_input.dart';
import '../../../core/widgets/layout/auth_form_card.dart';
import '../../../core/widgets/layout/brand_backdrop.dart';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.blue),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: BrandBackdrop()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: AuthFormCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeIn(
                      child: Center(
                        child: Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            color: AppColors.blue.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.mark_email_read_outlined,
                            color: AppColors.blue,
                            size: 38,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    FadeIn(
                      delay: Duration(milliseconds: 80),
                      child: Text(
                        'Enter reset code',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    FadeIn(
                      delay: const Duration(milliseconds: 120),
                      child: Text(
                        'Enter the 6-digit code sent to ${widget.args.email}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.inkMuted,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Center(
                      child: FadeIn(
                        delay: const Duration(milliseconds: 160),
                        child: OtpInput(
                          key: _otpKey,
                          onCompleted: (code) => _submit(code),
                          onChanged: (value) => setState(() => _code = value),
                          errorText: _errorText,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    FadeIn(
                      delay: const Duration(milliseconds: 200),
                      child: PrimaryButton(
                        label: 'Verify code',
                        loading: _loading,
                        onPressed: _code.length == 6 ? () => _submit() : null,
                        icon: Icons.arrow_forward,
                      ),
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
        ],
      ),
    );
  }
}
