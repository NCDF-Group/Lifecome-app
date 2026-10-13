import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/layout/app_header_bar.dart';

/// "Membership and billing" — the household plan, who is on it, and how
/// it is paid for. No membership backend exists yet, so the member list
/// and billing rows describe a single sample household (the signed-in
/// patient as account holder, plus one pending invitation) rather than
/// real account data.
class MembershipBillingScreen extends StatelessWidget {
  const MembershipBillingScreen({super.key});

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
              'Membership and billing',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Manage your household plan, payment and membership.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.inkMuted,
                height: 1.4,
              ),
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
                      Icons.family_restroom,
                      color: AppColors.greenStrong,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Adult household plan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          'Care for you and your household members.',
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
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Members',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Column(
                children: [
                  _MemberRow(
                    background: const Color(0xFFEAF7E8),
                    iconColor: AppColors.greenStrong,
                    name: 'You',
                    badge: 'Active',
                    badgeColor: AppColors.greenStrong,
                    badgeBackground: const Color(0xFFEAF7E8),
                    subtitle: 'Account holder',
                    onTap: () => showComingSoonPopup(
                      context,
                      feature: 'Your membership',
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.line),
                  _MemberRow(
                    background: const Color(0xFFE3EEFB),
                    iconColor: AppColors.blue,
                    name: 'Adult member',
                    badge: 'Invitation pending',
                    badgeColor: AppColors.blue,
                    badgeBackground: const Color(0xFFE3EEFB),
                    subtitle: 'Invitation sent',
                    onTap: () => showComingSoonPopup(
                      context,
                      feature: 'Managing a household member',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Billing and membership',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            _BillingRow(
              icon: Icons.credit_card_outlined,
              background: const Color(0xFFE3EEFB),
              iconColor: AppColors.blue,
              title: 'Payment method',
              subtitle: 'View and update your payment method.',
              onTap: () =>
                  showComingSoonPopup(context, feature: 'Payment method'),
            ),
            const SizedBox(height: AppSpacing.sm),
            _BillingRow(
              icon: Icons.description_outlined,
              background: const Color(0xFFEAF7E8),
              iconColor: AppColors.greenStrong,
              title: 'Billing history',
              subtitle: 'View your past payments and invoices.',
              onTap: () =>
                  showComingSoonPopup(context, feature: 'Billing history'),
            ),
            const SizedBox(height: AppSpacing.sm),
            _BillingRow(
              icon: Icons.sync_alt,
              background: const Color(0xFFE3EEFB),
              iconColor: AppColors.blue,
              title: 'Renewal and cancellation',
              subtitle: 'Manage your plan renewal or cancellation.',
              onTap: () => showComingSoonPopup(
                context,
                feature: 'Renewal and cancellation',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _BillingRow(
              icon: Icons.group_add_outlined,
              background: const Color(0xFFEAF7E8),
              iconColor: AppColors.greenStrong,
              title: 'Manage members',
              subtitle: 'Add or remove household members.',
              onTap: () =>
                  showComingSoonPopup(context, feature: 'Manage members'),
            ),
            const SizedBox(height: AppSpacing.lg),
            Material(
              color: AppColors.blue,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                onTap: () => context.push(RoutePaths.membershipPlans),
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Manage membership',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                      SizedBox(width: 8),
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
          ],
        ),
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.background,
    required this.iconColor,
    required this.name,
    required this.badge,
    required this.badgeColor,
    required this.badgeBackground,
    required this.subtitle,
    required this.onTap,
  });

  final Color background;
  final Color iconColor;
  final String name;
  final String badge;
  final Color badgeColor;
  final Color badgeBackground;
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
                backgroundColor: background,
                child: Icon(Icons.person_outline, color: iconColor),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBackground,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: badgeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.inkMuted,
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

class _BillingRow extends StatelessWidget {
  const _BillingRow({
    required this.icon,
    required this.background,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
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
              Icon(Icons.chevron_right, color: iconColor),
            ],
          ),
        ),
      ),
    );
  }
}
