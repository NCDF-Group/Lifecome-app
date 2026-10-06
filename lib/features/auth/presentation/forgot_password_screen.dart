import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/animation/fade_in.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/layout/auth_form_card.dart';
import '../../../core/widgets/layout/brand_backdrop.dart';
import '../data/auth_repository.dart';
import 'reset_password_screen.dart';
import '../../../core/widgets/feedback/app_popup.dart';

/// Step 1 of the forgot-password flow: enter the account email.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  String? _emailError;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());
  }

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();
    setState(
      () => _emailError = _isValidEmail(email)
          ? null
          : 'Enter a valid email address.',
    );
    if (_emailError != null) return;

    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).requestPasswordReset(email: email);
      if (!mounted) return;
      context.push(
        RoutePaths.resetPassword,
        extra: ResetPasswordArgs(email: email),
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      showErrorPopup(context, error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
                            Icons.lock_reset,
                            color: AppColors.blue,
                            size: 38,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const FadeIn(
                      delay: Duration(milliseconds: 80),
                      child: Text(
                        'Forgot your password?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const FadeIn(
                      delay: Duration(milliseconds: 120),
                      child: Text(
                        'Enter the email on your account and we will send you a code to reset your password.',
                        style: TextStyle(
                          fontSize: 14,
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
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.email],
                        prefixIcon: Icons.mail_outline,
                        errorText: _emailError,
                        onSubmitted: (_) => _sendCode(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    FadeIn(
                      delay: const Duration(milliseconds: 200),
                      child: PrimaryButton(
                        label: 'Send reset code',
                        loading: _loading,
                        onPressed: _sendCode,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FadeIn(
                      delay: const Duration(milliseconds: 240),
                      child: Center(
                        child: TextButton(
                          onPressed: () => context.pop(),
                          child: const Text(
                            'Back to sign in',
                            style: TextStyle(
                              color: AppColors.blue,
                              fontWeight: FontWeight.w700,
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
        ],
      ),
    );
  }
}
