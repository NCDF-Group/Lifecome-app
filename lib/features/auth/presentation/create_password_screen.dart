import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/layout/max_content_width.dart';
import '../application/auth_controller.dart';
import '../domain/models/auth_session.dart';
import 'widgets/auth_top_bar.dart';
import 'widgets/password_rules_checklist.dart';
import '../../../core/widgets/feedback/app_popup.dart';

/// The last step of sign-up: set a password now that the email is
/// verified. Nothing about which account this is for needs to be passed in
/// — [AuthController] already knows the email from the request/verify steps.
class CreatePasswordScreen extends ConsumerStatefulWidget {
  const CreatePasswordScreen({super.key});

  @override
  ConsumerState<CreatePasswordScreen> createState() =>
      _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends ConsumerState<CreatePasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _confirmError;
  String _password = '';

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    setState(() {
      _confirmError = confirm != password ? 'Passwords do not match.' : null;
    });
    if (_confirmError != null) return;

    final success = await ref
        .read(authControllerProvider.notifier)
        .completeSignUp(password);

    if (!mounted) return;
    if (success) {
      context.go(RoutePaths.signUpSuccess);
    } else {
      final message = ref.read(authControllerProvider).errorMessage;
      if (message != null) {
        showErrorPopup(context, message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final submitting = authState.status == AuthStatus.submitting;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: MaxContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AuthTopBar(),
                const SizedBox(height: AppSpacing.xl),
                const Text(
                  'Create Password',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'This password is used to sign in to your LifeCome Live account.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.inkMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppTextField(
                  label: 'Password',
                  controller: _passwordController,
                  hintText: 'Enter password',
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  onChanged: (value) => setState(() => _password = value),
                ),
                const SizedBox(height: AppSpacing.md),
                PasswordRulesChecklist(password: _password),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Confirm Password',
                  controller: _confirmController,
                  hintText: 'Re-enter password',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  errorText: _confirmError,
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: 'Continue',
                  icon: Icons.arrow_forward,
                  loading: submitting,
                  squared: true,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
