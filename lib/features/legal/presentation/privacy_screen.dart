import 'package:flutter/material.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/layout/back_app_bar.dart';

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
      backgroundColor: context.palette.background,
      appBar: const BackAppBar(
        title: 'Privacy Policy',
        fallback: RoutePaths.profile,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(
              'This policy explains what information LifeCome Live collects, how we use it, and '
              'the choices you have.',
              style: TextStyle(
                fontSize: 14,
                color: context.palette.ink,
                height: 1.5,
              ),
            ),
            for (final section in _sections) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                section.$1,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.palette.ink,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                section.$2,
                style: TextStyle(
                  fontSize: 14,
                  color: context.palette.inkMuted,
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
