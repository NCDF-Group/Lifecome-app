import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/animation/fade_in.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/layout/max_content_width.dart';
import 'personal_details_screen.dart';
import 'widgets/auth_top_bar.dart';
import 'widgets/step_indicator.dart';

/// View 01 (Create Account) — step 1 of 2. Collects the account basics:
/// full name, email and an optional referral code. Step 2
/// ([PersonalDetailsScreen]) collects date of birth and phone number, then
/// actually sends the verification code.
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _referralController = TextEditingController();
  String? _nameError;
  String? _emailError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());
  }

  void _continue() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    setState(() {
      _nameError = name.isEmpty ? 'Enter your full name.' : null;
      _emailError = _isValidEmail(email)
          ? null
          : 'Enter a valid email address.';
    });

    if (_nameError != null || _emailError != null) return;

    final referralCode = _referralController.text.trim();
    context.push(
      RoutePaths.personalDetails,
      extra: PersonalDetailsArgs(
        fullName: name,
        email: email,
        referralCode: referralCode.isEmpty ? null : referralCode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                const AuthTopBar(
                  trailing: StepIndicator(step: 1, totalSteps: 2),
                ),
                const SizedBox(height: AppSpacing.lg),
                FadeIn(
                  child: Center(
                    child: SvgPicture.asset(
                      AppColors.logoAsset,
                      height: 32,
                      semanticsLabel: 'LifeCome Live',
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Create your Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Enter your name and email below to create your account with us.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.inkMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppTextField(
                  label: 'Full Name',
                  controller: _nameController,
                  hintText: 'Enter Full Name',
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  errorText: _nameError,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Email (for verification)',
                  controller: _emailController,
                  hintText: 'Enter Email',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  errorText: _emailError,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Referral Code (Optional)',
                  controller: _referralController,
                  hintText: 'Enter referral code',
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: AppSpacing.lg),
                FadeIn(
                  child: PrimaryButton(
                    label: 'Continue',
                    icon: Icons.arrow_forward,
                    squared: true,
                    onPressed: _continue,
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
