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
import '../../../core/widgets/feedback/error_state.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/feedback/loading_indicator.dart';
import '../../../core/widgets/layout/back_app_bar.dart';
import '../../booking/application/booking_controller.dart';
import '../../booking/domain/models/booking_selection.dart';
import '../application/payer_controller.dart';
import '../domain/models/membership.dart';
import 'widgets/cover_badge.dart';

/// Blueprint view 08 — HMO Coverage & Benefits, shown once a membership has
/// been verified. The plan is asked, service by service, what it covers; what
/// is shown is its answer.
class HmoCoverageScreen extends ConsumerWidget {
  const HmoCoverageScreen({super.key, required this.plan});

  final LinkedPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final coverage = ref.watch(serviceCoverageProvider(plan.membership.id));
    final verifiedAt = plan.membership.verifiedAt;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: const BackAppBar(
        title: 'Your HMO coverage',
        fallback: RoutePaths.chooseAccess,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(
              'Your membership has been verified. Here is what your plan '
              'says about each service.',
              style: TextStyle(
                fontSize: 14,
                color: palette.inkMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: palette.tintGreen,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: palette.ink,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
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
                        if (verifiedAt != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Checked ${Formatters.date(verifiedAt)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: palette.inkMuted,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (plan.membership.planId != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Plan',
                          style: TextStyle(
                            fontSize: 12,
                            color: palette.inkMuted,
                          ),
                        ),
                        Text(
                          plan.membership.planId!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: palette.ink,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Your services',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: palette.ink,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            coverage.when(
              loading: () => const LoadingIndicator(),
              error: (error, _) => ErrorState(
                error: error,
                onRetry: () {
                  ref.invalidate(clinicalServicesProvider);
                  ref.invalidate(serviceCoverageProvider(plan.membership.id));
                },
              ),
              data: (items) => items.isEmpty
                  ? const EmptyState(
                      icon: Icons.medical_services_outlined,
                      title: 'No services to check yet',
                      message: 'Please check back soon.',
                    )
                  : Column(
                      children: [
                        for (final item in items) ...[
                          _ServiceRow(item: item),
                          const SizedBox(height: AppSpacing.xs),
                        ],
                      ],
                    ),
            ),
            const SizedBox(height: AppSpacing.md),
            const InfoBanner(
              message:
                  'Cover is checked again with your plan when you book. '
                  'Funding approval does not confirm clinical suitability.',
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Book covered care',
              onPressed: () => context.push(
                RoutePaths.bookingChooseService,
                extra: BookingStart.hmo(plan),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({required this.item});

  final ServiceCoverage item;

  @override
  Widget build(BuildContext context) {
    final service = item.service;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border.all(color: context.palette.line),
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Row(
        children: [
          Icon(
            Icons.medical_services_outlined,
            color: context.palette.positive,
            size: 22,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.palette.ink,
                  ),
                ),
                if (service.description != null)
                  Text(
                    service.description!,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.palette.inkMuted,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          CoverBadge(loading: false, coverage: item),
        ],
      ),
    );
  }
}
