import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/animation/fade_in.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/layout/auth_form_card.dart';
import '../application/auth_controller.dart';
import '../domain/models/auth_session.dart';
import '../../../core/widgets/feedback/app_popup.dart';

/// View 01 (Sign In). Email and password, matching a conventional login
/// form. The passwordless email-code flow lives on [CreateAccountScreen]
/// and [VerifyEmailScreen] instead, for first-time sign-up.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _emailError = _isValidEmail(email)
          ? null
          : 'Enter a valid email address.';
      _passwordError = password.isEmpty ? 'Enter your password.' : null;
    });

    if (_emailError != null || _passwordError != null) return;

    final success = await ref
        .read(authControllerProvider.notifier)
        .signIn(email: email, password: password, rememberMe: _rememberMe);

    if (!mounted) return;
    if (success) {
      context.go(
        ref.read(authControllerProvider).needsProfile
            ? RoutePaths.completeProfile
            : RoutePaths.home,
      );
    } else {
      final message = ref.read(authControllerProvider).errorMessage;
      if (message != null) {
        showErrorPopup(context, message);
      }
    }
  }

  void _forgotPassword() {
    context.push(RoutePaths.forgotPassword);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final submitting = authState.status == AuthStatus.submitting;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
          child: AuthFormCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeIn(
                  child: Center(
                    child: SvgPicture.asset(
                      AppColors.logoAsset,
                      height: 32,
                      semanticsLabel: 'LifeCome Live',
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                FadeIn(
                  delay: const Duration(milliseconds: 80),
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                        height: 1.15,
                      ),
                      children: [
                        const TextSpan(text: 'Welcome '),
                        const TextSpan(
                          text: 'back',
                          style: TextStyle(color: AppColors.blue),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                FadeIn(
                  delay: Duration(milliseconds: 120),
                  child: Text(
                    'Log in with your email and password.',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.inkMuted,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                FadeIn(
                  delay: const Duration(milliseconds: 160),
                  child: AppTextField(
                    label: 'Email',
                    controller: _emailController,
                    hintText: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    prefixIcon: Icons.mail_outline,
                    errorText: _emailError,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                FadeIn(
                  delay: const Duration(milliseconds: 200),
                  child: AppTextField(
                    label: 'Password',
                    controller: _passwordController,
                    hintText: 'Enter your password',
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    prefixIcon: Icons.lock_outline,
                    errorText: _passwordError,
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
                    onSubmitted: (_) => _login(),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                FadeIn(
                  delay: const Duration(milliseconds: 220),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () => setState(() => _rememberMe = !_rememberMe),
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) => setState(
                                    () => _rememberMe = value ?? false,
                                  ),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                'Remember me',
                                style: TextStyle(
                                  color: AppColors.inkMuted,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _forgotPassword,
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                            color: AppColors.blue,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                FadeIn(
                  delay: const Duration(milliseconds: 240),
                  child: PrimaryButton(
                    label: 'Login',
                    loading: submitting,
                    onPressed: _login,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                FadeIn(
                  delay: const Duration(milliseconds: 260),
                  child: Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: AppColors.inkMuted,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push(RoutePaths.createAccount),
                          child: const Text(
                            'Create one',
                            style: TextStyle(
                              color: AppColors.blue,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
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
