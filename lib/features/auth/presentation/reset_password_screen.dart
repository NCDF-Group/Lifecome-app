import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/router/safe_back.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/buttons/tinted_button.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/inputs/otp_input.dart';
import '../../../core/widgets/layout/max_content_width.dart';
import '../data/auth_repository.dart';
import 'new_password_screen.dart';
import 'widgets/auth_header.dart';
import 'widgets/otp_timer.dart';

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

  void _resetCodeInput() {
    _otpKey.currentState?.clear();
    setState(() => _code = '');
  }

  Future<void> _submit([String? completedCode]) async {
    if (_loading) return;
    final code = (completedCode ?? _code).trim();

    final invalid = Validators.otpCode(code);
    if (invalid != null) {
      setState(() => _errorText = invalid);
      return;
    }

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
      if (!mounted) return;
      setState(() => _errorText = error.message);
      _resetCodeInput();
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorText = 'Something went wrong. Please try again.');
      _resetCodeInput();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    try {
      await ref
          .read(authRepositoryProvider)
          .requestPasswordReset(email: widget.args.email);
      if (!mounted) return;
      setState(() {
        _errorText = null;
        _resendAvailableAt = DateTime.now().add(const Duration(seconds: 30));
      });
    } on AuthException catch (error) {
      if (!mounted) return;
      showErrorPopup(context, error.message);
    } catch (_) {
      if (!mounted) return;
      showErrorPopup(context, 'Could not resend the code. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.background,
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
                const AuthHeader(fallback: RoutePaths.forgotPassword),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  'Enter reset code',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: context.palette.ink,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontSize: 15,
                      color: context.palette.inkMuted,
                      height: 1.4,
                    ),
                    children: [
                      const TextSpan(text: 'Enter the 6-digit code sent to\n'),
                      TextSpan(
                        text: widget.args.email,
                        style: TextStyle(
                          color: context.palette.ink,
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
                  onChanged: (value) => setState(() {
                    _code = value;
                    _errorText = null;
                  }),
                  errorText: _errorText,
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: 'Verify code',
                  icon: Icons.arrow_forward,
                  loading: _loading,
                  onPressed: () => _submit(),
                ),
                const SizedBox(height: AppSpacing.sm),
                TintedButton(
                  label: 'Change email',
                  onPressed: () =>
                      context.goBack(fallback: RoutePaths.forgotPassword),
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
