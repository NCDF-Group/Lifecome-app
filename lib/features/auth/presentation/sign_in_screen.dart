import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/animation/fade_in.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/buttons/secondary_button.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/layout/max_content_width.dart';
import '../application/auth_controller.dart';
import '../domain/models/auth_session.dart';
import '../../../core/widgets/feedback/app_popup.dart';

/// View 01 (Sign In). Email and password, matching a conventional login
/// form. The single-page sign-up flow lives on [CreateAccountScreen] and
/// [VerifyMobileScreen] instead, for first-time sign-up.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
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
        .signIn(email: email, password: password);

    if (!mounted) return;
    if (success) {
      context.go(RoutePaths.home);
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
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: MaxContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeIn(
                  child: SvgPicture.asset(
                    'assets/images/logo/lifecome-live-logo.svg',
                    height: 28,
                    semanticsLabel: 'LifeCome Live',
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const FadeIn(
                  delay: Duration(milliseconds: 80),
                  child: Text(
                    'Welcome to LifeCome Live.',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                const FadeIn(
                  delay: Duration(milliseconds: 120),
                  child: Text(
                    'Your care, connected.',
                    style: TextStyle(fontSize: 16, color: AppColors.inkMuted),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                FadeIn(
                  delay: const Duration(milliseconds: 160),
                  child: AppTextField(
                    label: 'Email',
                    controller: _emailController,
                    hintText: 'Enter your email',
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
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _forgotPassword,
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: AppColors.blue,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                FadeIn(
                  delay: const Duration(milliseconds: 240),
                  child: PrimaryButton(
                    label: 'Sign in',
                    loading: submitting,
                    onPressed: _login,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                FadeIn(
                  delay: const Duration(milliseconds: 260),
                  child: SecondaryButton(
                    label: 'Create an account',
                    onPressed: () => context.push(RoutePaths.createAccount),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Divider(color: AppColors.line),
                const SizedBox(height: AppSpacing.md),
                FadeIn(
                  delay: const Duration(milliseconds: 280),
                  child: Center(
                    child: Text.rich(
                      TextSpan(
                        style: const TextStyle(
                          color: AppColors.inkMuted,
                          fontSize: 12,
                        ),
                        children: [
                          const TextSpan(
                            text: 'By continuing, you agree to our ',
                          ),
                          TextSpan(
                            text: 'Privacy notice',
                            style: const TextStyle(
                              color: AppColors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => showComingSoonPopup(
                                context,
                                feature: 'The privacy notice',
                              ),
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                FadeIn(
                  delay: const Duration(milliseconds: 300),
                  child: Center(
                    child: TextButton.icon(
                      onPressed: () =>
                          showComingSoonPopup(context, feature: 'Get help'),
                      icon: const Icon(
                        Icons.forum_outlined,
                        size: 16,
                        color: AppColors.blue,
                      ),
                      label: const Text(
                        'Get help',
                        style: TextStyle(
                          color: AppColors.blue,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
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
