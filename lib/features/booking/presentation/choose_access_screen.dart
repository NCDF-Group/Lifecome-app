import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../domain/models/booking_selection.dart';

/// "Choose your access" — how the patient wants to pay for or access care.
/// Reached from My Visits' "Book a consultation", replacing the old
/// coming-soon stub there.
class ChooseAccessScreen extends StatelessWidget {
  const ChooseAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const AppHeaderBar(showBack: true, backFallback: RoutePaths.visits),
            const SizedBox(height: 20),
            Text(
              'Choose your access',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: context.palette.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'We check eligibility for each booking. Your clinical account '
              'stays private.',
              style: TextStyle(
                fontSize: 14,
                color: context.palette.inkMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _AccessRow(
              background: context.palette.tintGreen,
              iconColor: context.palette.positive,
              icon: Icons.credit_card_outlined,
              title: 'Pay per visit',
              subtitle: 'Pay for the care you need.',
              onTap: () => context.push(
                RoutePaths.bookingChooseService,
                extra: const BookingStart.direct(),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _AccessRow(
              background: context.palette.tintBlue,
              iconColor: context.palette.accent,
              icon: Icons.landscape_outlined,
              title: 'Membership',
              subtitle: 'Explore individual or adult household options.',
              onTap: () => context.push(RoutePaths.membershipPlans),
            ),
            const SizedBox(height: AppSpacing.sm),
            _AccessRow(
              background: context.palette.tintBlue,
              iconColor: context.palette.accent,
              icon: Icons.apartment_outlined,
              title: 'Employer access',
              subtitle: 'Activate employer or sponsor access.',
              onTap: () => context.push(RoutePaths.activateAccess),
            ),
            const SizedBox(height: AppSpacing.sm),
            _AccessRow(
              background: context.palette.tintGreen,
              iconColor: context.palette.positive,
              icon: Icons.shield_outlined,
              title: 'Health plan access',
              subtitle: 'Link LifeCome Benefits or a participating plan.',
              onTap: () => context.push(RoutePaths.linkHealthPlan),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccessRow extends StatelessWidget {
  const _AccessRow({
    required this.background,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Color background;
  final Color iconColor;
  final IconData icon;
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
              CircleAvatar(
                radius: 22,
                backgroundColor: context.palette.elevated,
                child: Icon(icon, color: iconColor),
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
                        height: 1.3,
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
