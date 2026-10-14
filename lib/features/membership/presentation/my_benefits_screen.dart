import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/feedback/empty_state.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../booking/domain/models/booking_selection.dart';
import '../../payer/application/payer_controller.dart';
import '../../payer/domain/models/membership.dart';

/// "My benefits" — the health plans the person has linked, and what each one
/// covers.
///
/// The backend cannot list a person's memberships yet, so this shows the plans
/// verified since signing in; none is invented. With none, it says so and
/// points to linking one.
class MyBenefitsScreen extends ConsumerWidget {
  const MyBenefitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(linkedPlansProvider);

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
            const ScreenTitle(
              title: 'My benefits',
              subtitle:
                  'See what your health plan covers and book covered care.',
            ),
            const SizedBox(height: AppSpacing.md),
            if (plans.isEmpty) ...[
              EmptyState(
                icon: Icons.shield_outlined,
                title: 'No health plan linked yet',
                message:
                    'Link your health plan to see what it covers and to book '
                    'covered care. Plans you check while signed in show up '
                    'here.',
                actionLabel: 'Link a health plan',
                onAction: () => context.push(RoutePaths.linkHealthPlan),
              ),
              const SizedBox(height: AppSpacing.sm),
              _LinkRow(
                icon: Icons.apartment_outlined,
                title: 'Have an employer or membership code?',
                subtitle: 'Send it to our care team to activate your access.',
                onTap: () => context.push(RoutePaths.activateAccess),
              ),
            ] else ...[
              for (final plan in plans) ...[
                _PlanCard(plan: plan),
                const SizedBox(height: AppSpacing.sm),
              ],
              _LinkRow(
                icon: Icons.add_circle_outline,
                title: 'Link another plan',
                subtitle: 'Check a different health plan.',
                onTap: () => context.push(RoutePaths.linkHealthPlan),
              ),
              const SizedBox(height: AppSpacing.sm),
              const InfoBanner(
                message: 'Medicines, tests and specialist care may cost extra.',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan});

  final LinkedPlan plan;

  /// `•••• 3456`: enough to recognise the card, not enough to read it out.
  String _masked(String memberId) {
    final id = memberId.trim();
    return id.length <= 4 ? id : '•••• ${id.substring(id.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final verifiedAt = plan.membership.verifiedAt;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: palette.tintGreen,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: palette.elevated,
                child: Icon(Icons.shield_outlined, color: palette.positive),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: palette.ink,
                      ),
                    ),
                    Text(
                      [
                        'Membership ${_masked(plan.membership.memberId)}',
                        if (plan.membership.planId != null)
                          plan.membership.planId!,
                      ].join(' · '),
                      style: TextStyle(fontSize: 12.5, color: palette.inkMuted),
                    ),
                    if (verifiedAt != null)
                      Text(
                        'Checked ${Formatters.date(verifiedAt)}',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: palette.inkMuted,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.greenStrong,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: const Text(
                  'Verified',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            label: 'Book covered care',
            icon: Icons.arrow_forward,
            onPressed: () => context.push(
              RoutePaths.bookingChooseService,
              extra: BookingStart.hmo(plan),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Center(
            child: TextButton(
              onPressed: () =>
                  context.push(RoutePaths.payerCoverage, extra: plan),
              child: const Text('See what it covers'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
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
    final palette = context.palette;
    return Material(
      color: palette.tintBlue,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: palette.elevated,
                child: Icon(icon, size: 18, color: palette.accent),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: palette.ink,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12.5, color: palette.inkMuted),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: palette.accent),
            ],
          ),
        ),
      ),
    );
  }
}
