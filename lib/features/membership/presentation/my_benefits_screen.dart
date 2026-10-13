import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/layout/app_header_bar.dart';

/// "My benefits" — what the patient's plan includes and how to use it.
/// No membership backend exists yet, so the coverage rows describe
/// LifeCome's standard plan shape rather than a verified, per-account
/// benefit list.
class MyBenefitsScreen extends StatelessWidget {
  const MyBenefitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            AppHeaderBar(showBack: true, onBack: () => context.pop()),
            const SizedBox(height: 20),
            Text(
              'My benefits',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: context.palette.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'See what your plan includes and how to access care.',
              style: TextStyle(
                fontSize: 14,
                color: context.palette.inkMuted,
                height: 1.4,
              ),
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
                          'LifeCome Benefits',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: context.palette.ink,
                          ),
                        ),
                        SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 8,
                              color: context.palette.positive,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Connected',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: context.palette.positive,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Your plan is active and linked to this account.',
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
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: context.palette.line),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                children: [
                  _BenefitRow(
                    icon: Icons.desktop_windows_outlined,
                    background: context.palette.tintGreen,
                    iconColor: context.palette.positive,
                    title: 'Digital GP access',
                    subtitle: 'Care wherever you are.',
                    actionLabel: 'Check cover',
                    onTap: () =>
                        showComingSoonPopup(context, feature: 'Checking cover'),
                  ),
                  Divider(height: 1, color: context.palette.line),
                  _BenefitRow(
                    icon: Icons.apartment_outlined,
                    background: context.palette.tintBlue,
                    iconColor: context.palette.accent,
                    title: 'Clinic consultations',
                    subtitle: 'Care in person.',
                    actionLabel: 'Check separately',
                    onTap: () => context.push(RoutePaths.findSmartGpClinic),
                  ),
                  Divider(height: 1, color: context.palette.line),
                  _BenefitRow(
                    icon: Icons.groups_outlined,
                    background: context.palette.tintGreen,
                    iconColor: context.palette.positive,
                    title: 'Follow-up care',
                    subtitle: 'Coordinated when needed.',
                    actionLabel: 'Subject to your plan',
                    onTap: () => showComingSoonPopup(
                      context,
                      feature: 'Follow-up care details',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Material(
              color: AppColors.blue,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                onTap: () =>
                    showComingSoonPopup(context, feature: 'Checking a service'),
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.event_note_outlined,
                        color: AppColors.white,
                        size: 20,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Check a service',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: AppColors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Plan details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.palette.ink,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: context.palette.line),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                children: [
                  _PlanDetailRow(
                    icon: Icons.description_outlined,
                    title: 'Allowance and validity',
                    subtitle: 'View your allowance and plan dates.',
                    onTap: () => showComingSoonPopup(
                      context,
                      feature: 'Allowance and validity',
                    ),
                  ),
                  Divider(height: 1, color: context.palette.line),
                  _PlanDetailRow(
                    icon: Icons.apartment_outlined,
                    title: 'Funding provider',
                    subtitle: 'See who provides your plan.',
                    onTap: () => showComingSoonPopup(
                      context,
                      feature: 'Funding provider',
                    ),
                  ),
                  Divider(height: 1, color: context.palette.line),
                  _PlanDetailRow(
                    icon: Icons.description_outlined,
                    title: 'Terms and exclusions',
                    subtitle: "Read what's included and what's not.",
                    onTap: () => showComingSoonPopup(
                      context,
                      feature: 'Terms and exclusions',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: context.palette.tintBlue,
                borderRadius: BorderRadius.circular(AppRadius.control),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: context.palette.accent,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'Medicines, tests and specialist care may cost extra.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: context.palette.inkMuted,
                      ),
                    ),
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

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.icon,
    required this.background,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: background,
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
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        actionLabel,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
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
      ),
    );
  }
}

class _PlanDetailRow extends StatelessWidget {
  const _PlanDetailRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: context.palette.tintBlue,
                child: Icon(icon, color: context.palette.accent, size: 20),
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
