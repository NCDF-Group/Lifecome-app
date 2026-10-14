import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../payer/presentation/activate_access_screen.dart';

/// "Membership" — choose a LifeCome Live plan, or activate one already
/// bought elsewhere. No membership backend exists yet, so choosing a plan
/// opens a coming-soon popup rather than starting a real purchase; an
/// existing member can send their code to the care team.
class MembershipPlansScreen extends StatelessWidget {
  const MembershipPlansScreen({super.key});

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
              backFallback: RoutePaths.chooseAccess,
            ),
            const SizedBox(height: 20),
            Text(
              'Membership',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: context.palette.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Choose the option that's right for you.",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: context.palette.ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Fees, allowances and availability are shown before you join.',
              style: TextStyle(
                fontSize: 13,
                color: context.palette.inkMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _PlanCard(
              background: context.palette.tintGreen,
              accent: context.palette.positive,
              icon: Icons.person_outline,
              title: 'Individual membership',
              subtitle: 'For your own care.',
              bullets: const [
                'Access GP, clinics and services',
                'See fees, allowances and availability',
              ],
              onTap: () => showComingSoonPopup(
                context,
                feature: 'Individual membership',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _PlanCard(
              background: context.palette.tintBlue,
              accent: context.palette.accent,
              icon: Icons.people_outline,
              title: 'Adult household membership',
              subtitle: 'Separate accounts for each adult.',
              bullets: const [
                'Individual accounts for each adult',
                'See fees, allowances and availability',
              ],
              onTap: () => showComingSoonPopup(
                context,
                feature: 'Adult household membership',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Material(
              color: context.palette.elevated,
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.card),
                onTap: () => context.push(
                  RoutePaths.activateAccess,
                  extra: AccessKind.membership,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: context.palette.line),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: context.palette.tintBlue,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.description_outlined,
                          color: context.palette.accent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Existing member?',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: context.palette.ink,
                              ),
                            ),
                            Text(
                              'Activate your membership.',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: context.palette.inkMuted,
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
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.background,
    required this.accent,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.bullets,
    required this.onTap,
  });

  final Color background;
  final Color accent;
  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> bullets;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: context.palette.elevated,
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: context.palette.ink,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.palette.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: accent),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final bullet in bullets)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.check, size: 16, color: accent),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      bullet,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: context.palette.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          Material(
            color: AppColors.blue,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              onTap: onTap,
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'View benefits and pricing',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: AppColors.white, size: 20),
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
