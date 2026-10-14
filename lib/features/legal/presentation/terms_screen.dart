import 'package:flutter/material.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/layout/back_app_bar.dart';

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
      backgroundColor: context.palette.background,
      appBar: const BackAppBar(
        title: 'Terms and Conditions',
        fallback: RoutePaths.profile,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(
              'These terms govern your use of LifeCome Live. By creating an account, you agree '
              'to them.',
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
