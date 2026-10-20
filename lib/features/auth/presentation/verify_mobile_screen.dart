import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/router/safe_back.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/buttons/tinted_button.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/inputs/otp_input.dart';
import '../../../core/widgets/layout/max_content_width.dart';
import '../application/auth_controller.dart';
import '../domain/models/auth_session.dart';
import 'widgets/auth_header.dart';
import 'widgets/otp_timer.dart';

/// The email address the backend sent the code to.
class VerifyEmailArgs {
  const VerifyEmailArgs({required this.email});
  final String email;
}

/// Keeps enough of the address visible to identify the inbox without showing
/// the full local part, e.g. "alex@example.com" -> "a•••@example.com".
String _maskEmail(String email) {
  final separator = email.indexOf('@');
  if (separator < 1 || separator == email.length - 1) return email;
  final local = email.substring(0, separator);
  final visible = local.length == 1 ? local : local.substring(0, 1);
  return '$visible•••${email.substring(separator)}';
}

/// View 02 (Verify Email) — the last step of sign-up. The password was
/// already set on [CreateAccountScreen], so a correct code signs the
/// account straight in (see `AuthController.verifyCode`).
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key, required this.args});

  final VerifyEmailArgs args;

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

/// Source-compatible aliases for callers that still use the old mobile-flow names.
typedef VerifyMobileArgs = VerifyEmailArgs;
typedef VerifyMobileScreen = VerifyEmailScreen;

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final _otpKey = GlobalKey<OtpInputState>();
  String _code = '';

  /// What is wrong with the code as typed (too short...), before it is ever
  /// sent. The backend's own answer ("not correct", "expired") comes through
  /// the auth state instead.
  String? _codeError;

  Future<void> _submit([String? completedCode]) async {
    final code = (completedCode ?? _code).trim();

    final invalid = Validators.otpCode(code);
    if (invalid != null) {
      setState(() => _codeError = invalid);
      return;
    }
    setState(() => _codeError = null);

    final verified = await ref
        .read(authControllerProvider.notifier)
        .verifyCode(code);
    if (!mounted) return;

    if (verified) {
      context.go(RoutePaths.signUpSuccess);
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
                const AuthHeader(fallback: RoutePaths.createAccount),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Verify your email',
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
                        text: _maskEmail(widget.args.email),
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
                    _codeError = null;
                  }),
                  errorText: _codeError ?? authState.errorMessage,
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: 'Verify and continue',
                  icon: Icons.arrow_forward,
                  loading: verifying,
                  onPressed: () => _submit(),
                ),
                const SizedBox(height: AppSpacing.sm),
                TintedButton(
                  label: 'Back to sign up',
                  onPressed: () =>
                      context.goBack(fallback: RoutePaths.createAccount),
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
                const SizedBox(height: AppSpacing.lg),
                _InfoCard(
                  background: context.palette.tintGreen,
                  iconColor: context.palette.positive,
                  icon: Icons.mail_outline,
                  title: 'Check your inbox',
                  subtitle: "Check your spam folder if the verification email doesn't arrive.",
                  onTap: _showVerificationHelp,
                ),
                const SizedBox(height: AppSpacing.sm),
                _InfoCard(
                  background: context.palette.tintBlue,
                  iconColor: context.palette.accent,
                  icon: Icons.lock_outline,
                  title: 'Never share your code',
                  subtitle: 'Never share your verification code with anyone.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void _showVerificationHelp(BuildContext context) {
    showComingSoonPopup(context, feature: 'Verification help');
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.background,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final Color background;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final void Function(BuildContext context)? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: context.palette.elevated,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.palette.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: context.palette.inkMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(Icons.chevron_right, size: 18, color: iconColor),
        ],
      ),
    );

    if (onTap == null) return card;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.control),
      onTap: () => onTap!(context),
      child: card,
    );
  }
}
