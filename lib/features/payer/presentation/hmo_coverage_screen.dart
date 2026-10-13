import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../booking/domain/models/appointment.dart';

class _CoveredService {
  const _CoveredService({
    required this.icon,
    required this.title,
    required this.description,
    required this.covered,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool covered;
}

const _services = [
  _CoveredService(
    icon: Icons.videocam_outlined,
    title: 'GP Video Consultation',
    description: 'Consult a qualified doctor online.',
    covered: true,
  ),
  _CoveredService(
    icon: Icons.medical_information_outlined,
    title: 'Follow-up Consultation',
    description: 'Follow-up care for existing conditions.',
    covered: true,
  ),
  _CoveredService(
    icon: Icons.science_outlined,
    title: 'Laboratory Tests',
    description: 'Approved tests at partner laboratories.',
    covered: true,
  ),
  _CoveredService(
    icon: Icons.people_outline,
    title: 'Specialist Consultation',
    description: 'Subject to pre-authorisation.',
    covered: false,
  ),
];

/// Blueprint view 08 — HMO Coverage & Benefits, shown once membership has
/// been "verified" (no real payer integration exists yet — see
/// `VerifyHmoMembershipScreen`).
class HmoCoverageScreen extends StatelessWidget {
  const HmoCoverageScreen({super.key, required this.hmoName});

  final String hmoName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.background,
      appBar: AppBar(
        title: Text(
          'Your HMO coverage',
          style: TextStyle(
            color: context.palette.ink,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(
              'Your membership has been verified. Here are the services covered under your plan.',
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hmoName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: context.palette.ink,
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
                            'Active',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Plan type',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.palette.inkMuted,
                        ),
                      ),
                      Text(
                        'Premier Plan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: context.palette.ink,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Your covered services',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.palette.ink,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final service in _services) ...[
              _ServiceRow(service: service),
              const SizedBox(height: AppSpacing.xs),
            ],
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.palette.tintBlueFaint,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: context.palette.accent),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Not all services may be covered under your plan. Please check '
                      'service eligibility before booking.',
                      style: TextStyle(
                        fontSize: 13,
                        color: context.palette.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Book covered care',
              onPressed: () => context.push(
                RoutePaths.bookingChooseService,
                extra: (BookingAccessType.hmo, hmoName),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({required this.service});

  final _CoveredService service;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border.all(color: context.palette.line),
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Row(
        children: [
          Icon(service.icon, color: context.palette.positive, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.palette.ink,
                  ),
                ),
                Text(
                  service.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.palette.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: (service.covered ? AppColors.greenStrong : AppColors.gold)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              service.covered ? 'Covered' : 'Requires authorisation',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: service.covered
                    ? context.palette.positive
                    : context.palette.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
