import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/animation/fade_in.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/inputs/phone_number_field.dart';
import '../../../core/widgets/layout/max_content_width.dart';
import '../application/auth_controller.dart';
import '../domain/models/auth_session.dart';
import 'verify_email_screen.dart';
import 'widgets/auth_top_bar.dart';
import 'widgets/step_indicator.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/country/app_country.dart';

/// What step 1 ([CreateAccountScreen]) collected, carried forward so step 2
/// can send it all together when the verification code is requested.
class PersonalDetailsArgs {
  const PersonalDetailsArgs({
    required this.fullName,
    required this.email,
    this.referralCode,
  });

  final String fullName;
  final String email;
  final String? referralCode;
}

/// View 01 (Create Account) — step 2 of 2. Collects date of birth and
/// phone number, then sends the verification code with everything step 1
/// and step 2 collected together.
class PersonalDetailsScreen extends ConsumerStatefulWidget {
  const PersonalDetailsScreen({super.key, required this.args});

  final PersonalDetailsArgs args;

  @override
  ConsumerState<PersonalDetailsScreen> createState() =>
      _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends ConsumerState<PersonalDetailsScreen> {
  final _dobController = TextEditingController();
  DateTime? _dateOfBirth;
  String? _dobError;
  String _phoneNumber = '';

  @override
  void dispose() {
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25),
      firstDate: DateTime(now.year - 120),
      lastDate: now,
      helpText: 'Date of birth',
    );
    if (picked == null) return;
    setState(() {
      _dateOfBirth = picked;
      _dobController.text =
          '${picked.day.toString().padLeft(2, '0')} '
          '${_monthName(picked.month)} ${picked.year}';
      _dobError = null;
    });
  }

  String _monthName(int month) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[month - 1];
  }

  Future<void> _continue() async {
    setState(() {
      _dobError = _dateOfBirth == null ? 'Select your date of birth.' : null;
    });
    if (_dobError != null) return;

    final sent = await ref
        .read(authControllerProvider.notifier)
        .requestCode(
          flow: AuthFlow.createAccount,
          email: widget.args.email,
          fullName: widget.args.fullName,
          referralCode: widget.args.referralCode,
          phoneNumber: _phoneNumber.isEmpty ? null : _phoneNumber,
          dateOfBirth: _dateOfBirth,
        );

    if (!mounted) return;
    if (sent) {
      final country = AppCountry.fromPhoneNumber(_phoneNumber);
      if (country != null) ref.read(countryProvider.notifier).select(country);
      context.push(
        RoutePaths.verifyEmail,
        extra: VerifyEmailArgs(email: widget.args.email),
      );
    } else {
      final message = ref.read(authControllerProvider).errorMessage;
      if (message != null) {
        showErrorPopup(context, message);
      }
    }
  }

  void _openTerms() {
    showComingSoonPopup(context, feature: 'The terms of use page');
  }

  void _openPrivacy() {
    showComingSoonPopup(context, feature: 'The privacy notice');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final submitting = authState.status == AuthStatus.submitting;

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
                AuthTopBar(
                  onBack: () => context.pop(),
                  trailing: const StepIndicator(step: 2, totalSteps: 2),
                ),
                const SizedBox(height: AppSpacing.xl),
                const Text(
                  'Tell us about you',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Help your care team identify you correctly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.inkMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppTextField(
                  label: 'Date of Birth',
                  controller: _dobController,
                  hintText: 'Select date of birth',
                  readOnly: true,
                  onTap: _pickDateOfBirth,
                  errorText: _dobError,
                ),
                const SizedBox(height: AppSpacing.md),
                PhoneNumberField(
                  label: 'Phone Number (Optional)',
                  onChanged: (value) => _phoneNumber = value,
                ),
                const SizedBox(height: AppSpacing.lg),
                FadeIn(
                  child: PrimaryButton(
                    label: 'Continue',
                    icon: Icons.arrow_forward,
                    loading: submitting,
                    squared: true,
                    onPressed: _continue,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      color: AppColors.inkMuted,
                      fontSize: 12,
                      height: 1.4,
                    ),
                    children: [
                      const TextSpan(
                        text: 'By clicking continue, you agree to our ',
                      ),
                      TextSpan(
                        text: 'Terms of Service',
                        recognizer: TapGestureRecognizer()..onTap = _openTerms,
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        recognizer: TapGestureRecognizer()
                          ..onTap = _openPrivacy,
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
