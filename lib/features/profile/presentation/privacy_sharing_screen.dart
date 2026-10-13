import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/layout/app_header_bar.dart';

/// "Privacy and sharing" — who can access the patient's records and why.
/// No sharing backend exists yet (nothing has ever been granted access),
/// so every row here just opens a coming-soon popup for now; the one true
/// fact this screen states ("No sharing permissions active") is accurate
/// by construction, not sample data.
class PrivacySharingScreen extends StatelessWidget {
  const PrivacySharingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            AppHeaderBar(showBack: true, onBack: () => context.pop()),
            const SizedBox(height: 20),
            const Text(
              'Privacy and sharing',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'You control your information.',
              style: TextStyle(fontSize: 14, color: AppColors.inkMuted),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF7E8),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.white,
                    child: Icon(
                      Icons.shield_outlined,
                      color: AppColors.greenStrong,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sharing permissions',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.inkMuted,
                          ),
                        ),
                        Text(
                          'No sharing permissions active',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _PrivacyRow(
              icon: Icons.connect_without_contact,
              iconColor: AppColors.blue,
              background: const Color(0xFFE3EEFB),
              title: 'Request supported sharing',
              subtitle:
                  'Ask a trusted person, carer or organisation to access '
                  'your records.',
              onTap: () =>
                  showComingSoonPopup(context, feature: 'Supported sharing'),
            ),
            const SizedBox(height: AppSpacing.sm),
            _PrivacyRow(
              icon: Icons.description_outlined,
              iconColor: AppColors.greenStrong,
              background: const Color(0xFFEAF7E8),
              title: 'Review permissions',
              subtitle:
                  'See who can access your records and what they '
                  'can see.',
              onTap: () =>
                  showComingSoonPopup(context, feature: 'Review permissions'),
            ),
            const SizedBox(height: AppSpacing.sm),
            _PrivacyRow(
              icon: Icons.do_not_disturb_on_outlined,
              iconColor: AppColors.blue,
              background: const Color(0xFFE3EEFB),
              title: 'Revoke access',
              subtitle:
                  "Remove a person or organisation's access to your "
                  'records.',
              onTap: () =>
                  showComingSoonPopup(context, feature: 'Revoke access'),
            ),
            const SizedBox(height: AppSpacing.sm),
            _PrivacyRow(
              icon: Icons.history,
              iconColor: AppColors.greenStrong,
              background: const Color(0xFFEAF7E8),
              title: 'Access history',
              subtitle: 'See when your records have been accessed.',
              onTap: () =>
                  showComingSoonPopup(context, feature: 'Access history'),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFFE3EEFB),
                borderRadius: BorderRadius.circular(AppRadius.control),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 18, color: AppColors.blue),
                  SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Paying for care does not give access to your '
                          'records.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Sharing requires specific permission and can be '
                          'reviewed.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.inkMuted,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            InkWell(
              onTap: () => context.push(RoutePaths.privacyPolicy),
              child: const Row(
                children: [
                  Expanded(
                    child: Text(
                      'Read our privacy notice',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.blue,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 18, color: AppColors.blue),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyRow extends StatelessWidget {
  const _PrivacyRow({
    required this.icon,
    required this.iconColor,
    required this.background,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color background;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.inkMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.blue),
            ],
          ),
        ),
      ),
    );
  }
}
