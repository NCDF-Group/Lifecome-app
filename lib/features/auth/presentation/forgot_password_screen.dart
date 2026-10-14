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
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/layout/max_content_width.dart';
import '../data/auth_repository.dart';
import 'reset_password_screen.dart';
import 'widgets/auth_header.dart';

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

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();
    final error = Validators.email(email);
    setState(() => _emailError = error);
    if (error != null) return;

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
      if (error.fieldErrors.containsKey('email')) {
        setState(() => _emailError = error.fieldErrors['email']);
      } else {
        showErrorPopup(context, error.message);
      }
    } catch (_) {
      if (!mounted) return;
      showErrorPopup(context, 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
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
                const AuthHeader(fallback: RoutePaths.signIn),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  'Reset your password',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: context.palette.ink,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  "Enter your personal email and we'll send you a 6-digit code to reset your password.",
                  style: TextStyle(
                    fontSize: 15,
                    color: context.palette.inkMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'Email',
                  controller: _emailController,
                  hintText: 'Enter your email address',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.email],
                  errorText: _emailError,
                  onChanged: (_) {
                    if (_emailError != null) {
                      setState(() => _emailError = null);
                    }
                  },
                  onSubmitted: (_) => _sendCode(),
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: 'Send reset code',
                  icon: Icons.arrow_forward,
                  loading: _loading,
                  onPressed: _sendCode,
                ),
                const SizedBox(height: AppSpacing.sm),
                TintedButton(
                  label: 'Back to sign in',
                  onPressed: () => context.goBack(fallback: RoutePaths.signIn),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
