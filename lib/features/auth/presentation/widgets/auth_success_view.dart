import 'package:flutter/material.dart';

import '../../../../core/animation/fade_in.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/layout/auth_form_card.dart';
import '../../../../core/widgets/layout/brand_backdrop.dart';

/// The shared shape behind every "that flow is done" screen — sign-up
/// finishing and a password reset finishing both land here with their own
/// title, message and button.
class AuthSuccessView extends StatelessWidget {
  const AuthSuccessView({
    super.key,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onContinue,
  });

  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: BrandBackdrop()),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: AuthFormCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FadeIn(
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: AppColors.green.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: AppColors.greenStrong,
                            size: 48,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      FadeIn(
                        delay: const Duration(milliseconds: 80),
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      FadeIn(
                        delay: const Duration(milliseconds: 120),
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
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
                        child: PrimaryButton(
                          label: buttonLabel,
                          onPressed: onContinue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
