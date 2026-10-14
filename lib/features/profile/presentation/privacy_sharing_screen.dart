import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
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
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const AppHeaderBar(
              showBack: true,
              backFallback: RoutePaths.profile,
            ),
            const SizedBox(height: 20),
            Text(
              'Privacy and sharing',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: context.palette.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'You control your information.',
              style: TextStyle(fontSize: 14, color: context.palette.inkMuted),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.palette.tintGreen,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: context.palette.elevated,
                    child: Icon(
                      Icons.shield_outlined,
                      color: context.palette.positive,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sharing permissions',
                          style: TextStyle(
                            fontSize: 13,
                            color: context.palette.inkMuted,
                          ),
                        ),
                        Text(
                          'No sharing permissions active',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: context.palette.ink,
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
              iconColor: context.palette.accent,
              background: context.palette.tintBlue,
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
              iconColor: context.palette.positive,
              background: context.palette.tintGreen,
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
              iconColor: context.palette.accent,
              background: context.palette.tintBlue,
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
              iconColor: context.palette.positive,
              background: context.palette.tintGreen,
              title: 'Access history',
              subtitle: 'See when your records have been accessed.',
              onTap: () =>
                  showComingSoonPopup(context, feature: 'Access history'),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.palette.tintBlue,
                borderRadius: BorderRadius.circular(AppRadius.control),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: context.palette.accent,
                  ),
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
                            color: context.palette.ink,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Sharing requires specific permission and can be '
                          'reviewed.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: context.palette.inkMuted,
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
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Read our privacy notice',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: context.palette.accent,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: context.palette.accent,
                  ),
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
                decoration: BoxDecoration(
                  color: context.palette.elevated,
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
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: context.palette.ink,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: context.palette.inkMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: context.palette.accent),
            ],
          ),
        ),
      ),
    );
  }
}
