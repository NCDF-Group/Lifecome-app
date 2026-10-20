import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/feedback/empty_state.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/feedback/status_chip.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/layout/section_header.dart';
import '../../../core/widgets/lists/row_card.dart';
import '../../../core/widgets/media/lc_icons.dart';
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
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 25),
          children: [
            const AppHeaderBar(
              showBack: true,
              backFallback: RoutePaths.profile,
            ),
            const SizedBox(height: 4),
            const ScreenTitle(
              title: 'Your access & benefits',
              subtitle: 'Understand how you can access each service.',
            ),
            const SizedBox(height: 14),
            RowCard(
              icon: LcIcons.star,
              title: 'LifeCome membership',
              subtitle: 'Explore membership options',
              onTap: () => context.push(RoutePaths.membershipPlans),
            ),
            RowCard(
              icon: LcIcons.people,
              title: 'Employer access',
              subtitle: 'Activate a benefit from your employer',
              onTap: () => context.push(RoutePaths.activateAccess),
            ),
            RowCard(
              icon: LcIcons.shield,
              title: 'Insurance',
              subtitle: 'Policies, cover checks and claims',
              tone: RowCardTone.mint,
              onTap: () => context.push(RoutePaths.insurance),
            ),
            const SectionHeader(title: 'Health plans'),
            const SizedBox(height: 6),
            if (plans.isEmpty)
              EmptyState(
                icon: Icons.shield_outlined,
                title: 'No health plan linked yet',
                message:
                    'Link your health plan to see what it covers and to book '
                    'covered care. Plans you check while signed in show up '
                    'here.',
                actionLabel: 'Link a health plan',
                onAction: () => context.push(RoutePaths.linkHealthPlan),
              )
            else ...[
              for (final plan in plans) _PlanCard(plan: plan),
              RowCard(
                icon: LcIcons.plus,
                title: 'Link another plan',
                subtitle: 'Check a different health plan',
                tone: RowCardTone.white,
                onTap: () => context.push(RoutePaths.linkHealthPlan),
              ),
            ],
            const SizedBox(height: 10),
            const InfoBanner(
              message:
                  'Membership benefits and health plan cover are managed '
                  'separately. Eligibility is checked for the service you '
                  'choose. Medicines, tests and specialist care may cost '
                  'extra.',
            ),
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
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.elevated,
        border: Border.all(color: palette.line),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: palette.tintGreenStrong,
                child: LcIcon(LcIcons.shield, color: palette.positive),
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
                        fontWeight: FontWeight.w700,
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
              const StatusBadge('Verified'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            label: 'Book covered care',
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
