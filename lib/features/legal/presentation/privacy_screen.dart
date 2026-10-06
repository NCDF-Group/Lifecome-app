import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/design/soft_widgets.dart';

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
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            const DesignBackButton(),
            const SizedBox(height: 14),
            const PageHeading(
              'Privacy Policy',
              subtitle: 'Last updated: 30 September 2026',
            ),
            const SizedBox(height: 20),
            const Text(
              'This policy explains what information LifeCome Live collects, how we use it, and the choices you have.',
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                letterSpacing: -0.2,
                color: AppColors.textPrimary,
              ),
            ),
            for (final section in _sections) ...[
              const SizedBox(height: 16),
              SoftCard(
                radius: 14,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.$1,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      section.$2,
                      style: const TextStyle(
                        fontSize: 14.5,
                        height: 1.5,
                        letterSpacing: -0.2,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
