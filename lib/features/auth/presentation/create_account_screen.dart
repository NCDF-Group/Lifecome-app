import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/animation/fade_in.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/inputs/phone_number_field.dart';
import '../../../core/widgets/layout/max_content_width.dart';
import '../application/auth_controller.dart';
import '../domain/models/auth_session.dart';
import 'verify_mobile_screen.dart';
import 'widgets/auth_header.dart';
import 'widgets/password_rules_checklist.dart';

/// View 01 (Create Account) — one page: name, email, mobile number and
/// password together, matching the app's current single-step sign-up
/// design. Sends the first verification code to the email address
/// (see `AuthController.signUp`); [VerifyEmailScreen] is the only step
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

  /// Errors stay quiet until the first attempt to submit; after that each
  /// field re-checks as it is edited, so a message clears the moment it is
  /// fixed.
  bool _submitted = false;

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

  /// Checks every field and shows what is wrong. Returns true when all pass.
  bool _validate() {
    setState(() {
      _firstNameError = Validators.personName(
        _firstNameController.text,
        label: 'first name',
      );
      _lastNameError = Validators.personName(
        _lastNameController.text,
        label: 'last name',
      );
      _emailError = Validators.email(_emailController.text);
      _phoneError = Validators.ukMobile(_phoneNumber);
      _passwordError = Validators.newPassword(_passwordController.text);
      _confirmError = Validators.confirmPassword(
        _confirmController.text,
        _passwordController.text,
      );
      _termsError = _agreedToTerms
          ? null
          : 'You must agree to the terms of use.';
    });

    return [
      _firstNameError,
      _lastNameError,
      _emailError,
      _phoneError,
      _passwordError,
      _confirmError,
      _termsError,
    ].every((error) => error == null);
  }

  /// Re-checks as the person types, once they have tried to submit.
  void _revalidate() {
    if (_submitted) _validate();
  }

  /// Shows the backend's own complaints under the right fields.
  void _showServerErrors(Map<String, String> errors) {
    setState(() {
      _firstNameError = errors['firstName'] ?? _firstNameError;
      _lastNameError = errors['lastName'] ?? _lastNameError;
      _emailError = errors['email'] ?? _emailError;
      _phoneError = errors['phoneNumber'] ?? _phoneError;
      _passwordError = errors['password'] ?? _passwordError;
    });
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!_validate()) return;

    final phoneNumber = Validators.normalizeUkMobile(_phoneNumber)!;
    final email = _emailController.text.trim();

    final sent = await ref
        .read(authControllerProvider.notifier)
        .signUp(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: email,
          phoneNumber: phoneNumber,
          password: _passwordController.text,
        );

    if (!mounted) return;
    if (sent) {
      context.push(
        RoutePaths.verifyEmail,
        extra: VerifyEmailArgs(email: email),
      );
    } else {
      final state = ref.read(authControllerProvider);
      if (state.fieldErrors.isNotEmpty) {
        _showServerErrors(state.fieldErrors);
      } else if (state.errorMessage != null) {
        showErrorPopup(context, state.errorMessage!);
      }
    }
  }

  void _openTerms() => context.push(RoutePaths.termsAndConditions);

  void _openPrivacy() => context.push(RoutePaths.privacyPolicy);

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final submitting = authState.status == AuthStatus.submitting;

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
                const FadeIn(child: AuthHeader()),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Create your account',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: context.palette.ink,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Set up your account to access your care.',
                  style: TextStyle(
                    fontSize: 15,
                    color: context.palette.inkMuted,
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
                  onChanged: (_) => _revalidate(),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Last name',
                  controller: _lastNameController,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.familyName],
                  errorText: _lastNameError,
                  onChanged: (_) => _revalidate(),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Personal email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  errorText: _emailError,
                  onChanged: (_) => _revalidate(),
                ),
                const SizedBox(height: AppSpacing.md),
                PhoneNumberField(
                  label: 'Mobile number',
                  onChanged: (value) {
                    _phoneNumber = value;
                    _revalidate();
                  },
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
                  onChanged: (value) {
                    setState(() => _password = value);
                    _revalidate();
                  },
                  suffixIcon: IconButton(
                    tooltip: _obscurePassword
                        ? 'Show password'
                        : 'Hide password',
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: context.palette.inkMuted,
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
                  onChanged: (_) => _revalidate(),
                  onSubmitted: (_) => _submit(),
                  suffixIcon: IconButton(
                    tooltip: _obscureConfirm
                        ? 'Show password'
                        : 'Hide password',
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: context.palette.inkMuted,
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
                        onChanged: (value) {
                          setState(() => _agreedToTerms = value ?? false);
                          _revalidate();
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text.rich(
                          TextSpan(
                            style: TextStyle(
                              color: context.palette.inkMuted,
                              fontSize: 14,
                            ),
                            children: [
                              const TextSpan(text: 'I agree to the '),
                              TextSpan(
                                text: 'Terms of use',
                                style: TextStyle(
                                  color: context.palette.accent,
                                  fontWeight: FontWeight.w600,
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
                    style: TextStyle(
                      fontSize: 12,
                      color: context.palette.danger,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xxs),
                Text.rich(
                  TextSpan(
                    style: TextStyle(
                      color: context.palette.inkMuted,
                      fontSize: 12,
                      height: 1.4,
                    ),
                    children: [
                      const TextSpan(text: 'See our '),
                      TextSpan(
                        text: 'Privacy notice',
                        style: TextStyle(
                          color: context.palette.accent,
                          fontWeight: FontWeight.w600,
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
                    color: context.palette.tintGreen,
                    borderRadius: BorderRadius.circular(AppRadius.control),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: context.palette.positive,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          'Use your own contact details, even when someone else pays.',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: context.palette.ink,
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
