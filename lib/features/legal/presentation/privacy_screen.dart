import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

const _sections = [
  (
    'Information we collect',
    'We collect the information you give us when you create an account — your name, email, '
        'phone number and date of birth — along with health information you share during '
        'consultations, such as symptoms, visit notes and prescriptions.',
  ),
  (
    'How we use your information',
    'We use your information to provide care (connecting you with doctors, scheduling visits, '
        'maintaining your health records) and to operate the app (account security, service '
        'notifications, and improving LifeCome Live).',
  ),
  (
    'Who we share it with',
    "We share clinical information with the doctors and care team involved in your treatment, "
        "and with your HMO when you book a visit through them. We don't sell your personal or "
        'health information to third parties.',
  ),
  (
    'Your rights',
    'You can request a copy of your data, ask us to correct it, or request deletion of your '
        'account at any time from the Profile tab.',
  ),
  (
    'Contact us',
    'Questions about this policy can be sent to our patient support team from the Help & '
        'Support section of the app.',
  ),
];

/// Placeholder privacy policy copy — a legal/compliance team should review
/// and finalise the actual wording before release.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const Text(
              'Last updated: 30 September 2026',
              style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'This policy explains what information LifeCome Live collects, how we use it, and '
              'the choices you have.',
              style: TextStyle(fontSize: 14, color: AppColors.ink, height: 1.5),
            ),
            for (final section in _sections) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                section.$1,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                section.$2,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.inkMuted,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
