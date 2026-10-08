import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/animation/fade_in.dart';
import '../../../core/country/app_country.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/inputs/phone_number_field.dart';
import '../../../core/widgets/layout/max_content_width.dart';
import '../application/auth_controller.dart';
import '../domain/models/auth_session.dart';
import 'verify_mobile_screen.dart';
import 'widgets/password_rules_checklist.dart';

/// View 01 (Create Account) — one page: name, email, mobile number and
/// password together, matching the app's current single-step sign-up
/// design. Sends the first verification code by SMS to the mobile number
/// (see `AuthController.signUp`); [VerifyMobileScreen] is the only step
/// after this one.
class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  ConsumerState<CreateAccountScreen> createState() =>
      _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  String _phoneNumber = '';
  String _password = '';
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = false;

  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmError;
  String? _termsError;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());
  }

  Future<void> _submit() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    setState(() {
      _firstNameError = firstName.isEmpty ? 'Enter your first name.' : null;
      _lastNameError = lastName.isEmpty ? 'Enter your last name.' : null;
      _emailError = _isValidEmail(email)
          ? null
          : 'Enter a valid email address.';
      _phoneError = _phoneNumber.isEmpty ? 'Enter your mobile number.' : null;
      _passwordError = password.length < 8
          ? 'Your password must be at least 8 characters.'
          : null;
      _confirmError = confirm != password ? 'Passwords do not match.' : null;
      _termsError = _agreedToTerms
          ? null
          : 'You must agree to the terms of use.';
    });

    if ([
      _firstNameError,
      _lastNameError,
      _emailError,
      _phoneError,
      _passwordError,
      _confirmError,
      _termsError,
    ].any((error) => error != null)) {
      return;
    }

    final sent = await ref
        .read(authControllerProvider.notifier)
        .signUp(
          firstName: firstName,
          lastName: lastName,
          email: email,
          phoneNumber: _phoneNumber,
          password: password,
        );

    if (!mounted) return;
    if (sent) {
      final country = AppCountry.fromPhoneNumber(_phoneNumber);
      if (country != null) ref.read(countryProvider.notifier).select(country);
      context.push(
        RoutePaths.verifyMobile,
        extra: VerifyMobileArgs(email: email, phoneNumber: _phoneNumber),
      );
    } else {
      final message = ref.read(authControllerProvider).errorMessage;
      if (message != null) showErrorPopup(context, message);
    }
  }

  void _openTerms() =>
      showComingSoonPopup(context, feature: 'The terms of use page');

  void _openPrivacy() =>
      showComingSoonPopup(context, feature: 'The privacy notice');

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
                FadeIn(
                  child: Row(
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
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Create your account',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                const Text(
                  'Set up your account to access your care.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.inkMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'First name',
                  controller: _firstNameController,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.givenName],
                  errorText: _firstNameError,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Last name',
                  controller: _lastNameController,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.familyName],
                  errorText: _lastNameError,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Personal email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  errorText: _emailError,
                ),
                const SizedBox(height: AppSpacing.md),
                PhoneNumberField(
                  label: 'Mobile number',
                  onChanged: (value) => _phoneNumber = value,
                  errorText: _phoneError,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  errorText: _passwordError,
                  onChanged: (value) => setState(() => _password = value),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: AppColors.inkMuted,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                PasswordRulesChecklist(password: _password),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Confirm password',
                  controller: _confirmController,
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  errorText: _confirmError,
                  onSubmitted: (_) => _submit(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: AppColors.inkMuted,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: _agreedToTerms,
                        onChanged: (value) => setState(() {
                          _agreedToTerms = value ?? false;
                          _termsError = null;
                        }),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text.rich(
                          TextSpan(
                            style: const TextStyle(
                              color: AppColors.inkMuted,
                              fontSize: 14,
                            ),
                            children: [
                              const TextSpan(text: 'I agree to the '),
                              TextSpan(
                                text: 'Terms of use',
                                style: const TextStyle(
                                  color: AppColors.blue,
                                  fontWeight: FontWeight.w700,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = _openTerms,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_termsError != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    _termsError!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.error,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xxs),
                Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      color: AppColors.inkMuted,
                      fontSize: 12,
                      height: 1.4,
                    ),
                    children: [
                      const TextSpan(text: 'See our '),
                      TextSpan(
                        text: 'Privacy notice',
                        style: const TextStyle(
                          color: AppColors.blue,
                          fontWeight: FontWeight.w700,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = _openPrivacy,
                      ),
                      const TextSpan(
                        text: ' to learn how we use your information.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                FadeIn(
                  child: PrimaryButton(
                    label: 'Create account',
                    icon: Icons.arrow_forward,
                    loading: submitting,
                    onPressed: _submit,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF7E8),
                    borderRadius: BorderRadius.circular(AppRadius.control),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: AppColors.greenStrong,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          'Use your own contact details, even when someone else pays.',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
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
