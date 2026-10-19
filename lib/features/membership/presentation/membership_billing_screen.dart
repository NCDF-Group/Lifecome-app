import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/feedback/empty_state.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/screen_title.dart';

/// "Membership and billing" — the household plan, who is on it, and how it is
/// paid for.
///
/// The backend has no membership or billing records to return yet, so there is
/// no plan, member or payment to show. The screen says so instead of
/// describing an invented household.
class MembershipBillingScreen extends StatelessWidget {
  const MembershipBillingScreen({super.key});

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
            const SizedBox(height: 4),
            const ScreenTitle(
              title: 'Membership and billing',
              subtitle: 'Your plan, household members and payments.',
            ),
            const SizedBox(height: AppSpacing.md),
            EmptyState(
              icon: Icons.groups_outlined,
              title: 'Nothing to show yet',
              message:
                  'Your membership, household members and billing will '
                  'appear here once membership is available in the app. You '
                  'can still book and pay per visit.',
              actionLabel: 'Explore membership',
              onAction: () => context.push(RoutePaths.membershipPlans),
            ),
          ],
        ),
      ),
    );
  }
}
