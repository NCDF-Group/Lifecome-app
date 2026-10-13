import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/buttons/tinted_button.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/inputs/otp_input.dart';
import '../../../core/widgets/layout/max_content_width.dart';
import '../application/auth_controller.dart';
import '../domain/models/auth_session.dart';
import 'widgets/otp_timer.dart';

/// What this screen needs to know: which account the code was sent for
/// (the backend keys verification off `email`, see `AuthRepository`), and
/// the phone number it went to, shown masked.
class VerifyMobileArgs {
  const VerifyMobileArgs({required this.email, required this.phoneNumber});
  final String email;
  final String phoneNumber;
}

/// Masks all but the dial code and last 4 digits, e.g. "+447700900123" ->
/// "+44 •••• ••0123".
String _maskPhoneNumber(String phoneNumber) {
  final dialCode = RegExp(r'^\+\d{1,4}').stringMatch(phoneNumber) ?? '';
  final local = phoneNumber.substring(dialCode.length);
  if (local.length < 4) return phoneNumber;
  final last4 = local.substring(local.length - 4);
  return '$dialCode •••• ••$last4';
}

/// View 02 (Verify Mobile) — the last step of sign-up. The password was
/// already set on [CreateAccountScreen], so a correct code signs the
/// account straight in (see `AuthController.verifyCode`).
class VerifyMobileScreen extends ConsumerStatefulWidget {
  const VerifyMobileScreen({super.key, required this.args});

  final VerifyMobileArgs args;

  @override
  ConsumerState<VerifyMobileScreen> createState() => _VerifyMobileScreenState();
}

class _VerifyMobileScreenState extends ConsumerState<VerifyMobileScreen> {
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
                Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => context.pop(),
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: context.palette.ink,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SvgPicture.asset(
                      context.palette.logoAsset,
                      height: 24,
                      semanticsLabel: 'LifeCome Live',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Verify your mobile',
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
                        text: _maskPhoneNumber(widget.args.phoneNumber),
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
                  onChanged: (value) => setState(() => _code = value),
                  errorText: authState.errorMessage,
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: 'Verify and continue',
                  icon: Icons.arrow_forward,
                  loading: verifying,
                  onPressed: _code.length == 6 ? () => _submit() : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                TintedButton(
                  label: 'Change number',
                  onPressed: () => context.pop(),
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
                  icon: Icons.sms_outlined,
                  title: 'Get verification help',
                  subtitle: "See options if you're having trouble receiving your code.",
                  onTap: _showVerificationHelp,
                ),
                const SizedBox(height: AppSpacing.sm),
                _InfoCard(
                  background: context.palette.tintBlue,
                  iconColor: context.palette.accent,
                  icon: Icons.lock_outline,
                  title: 'Never share your code',
                  subtitle: 'LifeCome Live will never ask for your code by phone, email or text.',
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
