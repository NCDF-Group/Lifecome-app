import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/design/soft_widgets.dart';

const _sections = [
  (
    'Using LifeCome Live',
    'LifeCome Live connects you with licensed healthcare providers for online consultations. '
        'You must provide accurate information about yourself and your health when using the app.',
  ),
  (
    'Medical emergencies',
    'LifeCome Live is not an emergency service. If you are experiencing a medical emergency, '
        'seek immediate in-person care rather than waiting for a response in the app.',
  ),
  (
    'Payments and HMO cover',
    'Services booked directly are charged at the price shown before you confirm. Services '
        'booked through an HMO are subject to your plan\'s coverage, which we check before booking.',
  ),
  (
    'Your account',
    "You're responsible for keeping your password secure. Let us know immediately if you "
        'suspect unauthorised access to your account.',
  ),
  (
    'Changes to these terms',
    'We may update these terms from time to time. We will let you know about significant '
        'changes before they take effect.',
  ),
];

/// Placeholder terms-of-service copy — a legal/compliance team should
/// review and finalise the actual wording before release.
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
              'Terms and Conditions',
              subtitle: 'Last updated: 30 September 2026',
            ),
            const SizedBox(height: 20),
            const Text(
              'These terms govern your use of LifeCome Live. By creating an account, you agree to them.',
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
