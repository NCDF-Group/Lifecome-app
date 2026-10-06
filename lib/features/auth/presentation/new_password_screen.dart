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
import 'widgets/password_rules_checklist.dart';

/// What this screen needs to know: which email and (already-verified)
/// reset code to submit alongside the new password.
class NewPasswordArgs {
  const NewPasswordArgs({required this.email, required this.code});
  final String email;
  final String code;
}

/// Step 3 of the forgot-password flow: choose a new password.
class NewPasswordScreen extends ConsumerStatefulWidget {
  const NewPasswordScreen({super.key, required this.args});

  final NewPasswordArgs args;

  @override
  ConsumerState<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends ConsumerState<NewPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _passwordError;
  String? _confirmError;
  String _password = '';
  bool _loading = false;

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
      _passwordError = password.length < 8
          ? 'Use at least 8 characters.'
          : null;
      _confirmError = confirm != password ? 'Passwords do not match.' : null;
    });

    if (_passwordError != null || _confirmError != null) return;

    setState(() => _loading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .setNewPassword(
            email: widget.args.email,
            code: widget.args.code,
            newPassword: password,
          );
      if (!mounted) return;
      context.go(RoutePaths.passwordChanged);
    } on AuthException catch (error) {
      setState(() => _passwordError = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
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
                            Icons.lock_outline,
                            color: AppColors.blue,
                            size: 38,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    FadeIn(
                      delay: Duration(milliseconds: 80),
                      child: Text(
                        'Choose a new password',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    FadeIn(
                      delay: Duration(milliseconds: 120),
                      child: Text(
                        'Use at least 8 characters. You will use this password to sign in from now on.',
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
                        label: 'New password',
                        controller: _passwordController,
                        hintText: 'Enter new password',
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.newPassword],
                        prefixIcon: Icons.lock_outline,
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
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    FadeIn(
                      delay: const Duration(milliseconds: 180),
                      child: PasswordRulesChecklist(password: _password),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FadeIn(
                      delay: const Duration(milliseconds: 200),
                      child: AppTextField(
                        label: 'Confirm new password',
                        controller: _confirmController,
                        hintText: 'Re-enter new password',
                        obscureText: _obscureConfirm,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.newPassword],
                        prefixIcon: Icons.lock_outline,
                        errorText: _confirmError,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                            color: AppColors.inkMuted,
                          ),
                          onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                        ),
                        onSubmitted: (_) => _submit(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    FadeIn(
                      delay: const Duration(milliseconds: 240),
                      child: PrimaryButton(
                        label: 'Reset password',
                        loading: _loading,
                        onPressed: _submit,
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
