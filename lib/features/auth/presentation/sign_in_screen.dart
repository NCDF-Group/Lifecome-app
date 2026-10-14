import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/animation/fade_in.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/buttons/secondary_button.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/layout/max_content_width.dart';
import '../application/auth_controller.dart';
import '../domain/models/auth_session.dart';
import 'widgets/auth_header.dart';

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

  /// Errors stay quiet until the first attempt to sign in; after that each
  /// field re-checks as it is edited, so a message clears the moment it is
  /// fixed.
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Checks both fields and shows what is wrong. Returns true when both pass.
  bool _validate() {
    setState(() {
      _emailError = Validators.email(_emailController.text);
      _passwordError = Validators.currentPassword(_passwordController.text);
    });
    return _emailError == null && _passwordError == null;
  }

  void _revalidate() {
    if (_submitted) _validate();
  }

  Future<void> _login() async {
    setState(() => _submitted = true);
    if (!_validate()) return;

    final success = await ref
        .read(authControllerProvider.notifier)
        .signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FadeIn(child: AuthHeader()),
                const SizedBox(height: AppSpacing.lg),
                FadeIn(
                  delay: const Duration(milliseconds: 80),
                  child: Text(
                    'Welcome to LifeCome Live.',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: context.palette.ink,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                FadeIn(
                  delay: const Duration(milliseconds: 120),
                  child: Text(
                    'Your care, connected.',
                    style: TextStyle(
                      fontSize: 16,
                      color: context.palette.inkMuted,
                    ),
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
                    onChanged: (_) => _revalidate(),
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
                    onChanged: (_) => _revalidate(),
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
                      child: Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: context.palette.accent,
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
                Divider(color: context.palette.line),
                const SizedBox(height: AppSpacing.md),
                FadeIn(
                  delay: const Duration(milliseconds: 280),
                  child: Center(
                    child: Text.rich(
                      TextSpan(
                        style: TextStyle(
                          color: context.palette.inkMuted,
                          fontSize: 12,
                        ),
                        children: [
                          const TextSpan(
                            text: 'By continuing, you agree to our ',
                          ),
                          TextSpan(
                            text: 'Privacy notice',
                            style: TextStyle(
                              color: context.palette.accent,
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
                      icon: Icon(
                        Icons.forum_outlined,
                        size: 16,
                        color: context.palette.accent,
                      ),
                      label: Text(
                        'Get help',
                        style: TextStyle(
                          color: context.palette.accent,
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
