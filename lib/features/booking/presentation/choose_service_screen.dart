import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../domain/models/appointment.dart';
import '../domain/models/clinical_service.dart';

/// Blueprint views 09 (Check Service Eligibility, HMO path) and 10 (Choose a
/// Service, direct-pay path) — the same underlying choice, so one screen
/// serves both, showing coverage badges only when booking through an HMO.
class ChooseServiceScreen extends StatefulWidget {
  const ChooseServiceScreen({
    super.key,
    required this.accessType,
    this.hmoName,
  });

  final BookingAccessType accessType;
  final String? hmoName;

  @override
  State<ChooseServiceScreen> createState() => _ChooseServiceScreenState();
}

class _ChooseServiceScreenState extends State<ChooseServiceScreen> {
  ClinicalService _selected = clinicalServices.first;

  bool get _isHmo => widget.accessType == BookingAccessType.hmo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          _isHmo ? 'Check service eligibility' : 'Choose a service',
          style: const TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  Text(
                    _isHmo
                        ? 'What care do you need?'
                        : 'What care do you need?',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  if (_isHmo && widget.hmoName != null)
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF7E8),
                        borderRadius: BorderRadius.circular(AppRadius.control),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.health_and_safety_outlined,
                            color: AppColors.greenStrong,
                            size: 18,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'Access: ${widget.hmoName}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  for (final service in clinicalServices) ...[
                    _ServiceTile(
                      service: service,
                      selected: service.id == _selected.id,
                      isHmo: _isHmo,
                      onTap: () => setState(() => _selected = service),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _isHmo
                        ? 'Eligibility may vary by plan type and HMO rules.'
                        : 'You will see your total before payment.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: PrimaryButton(
                label: 'Continue to find a doctor',
                icon: Icons.arrow_forward,
                onPressed: () => context.push(
                  RoutePaths.doctorsFindADoctor,
                  extra: BookingSelection(
                    accessType: widget.accessType,
                    hmoName: widget.hmoName,
                    service: _selected,
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

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.service,
    required this.selected,
    required this.isHmo,
    required this.onTap,
  });

  final ClinicalService service;
  final bool selected;
  final bool isHmo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFE8F4FC) : AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: selected ? AppColors.blue : AppColors.line,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      service.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.inkMuted,
                      ),
                    ),
                    if (!isHmo) ...[
                      const SizedBox(height: 4),
                      Text(
                        '₦${service.fee}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.blue,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isHmo)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (service.requiresAuthorisation
                                ? AppColors.gold
                                : AppColors.greenStrong)
                            .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    service.requiresAuthorisation
                        ? 'Requires authorisation'
                        : 'Covered',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: service.requiresAuthorisation
                          ? AppColors.gold
                          : AppColors.greenStrong,
                    ),
                  ),
                )
              else if (selected)
                const Icon(Icons.check_circle, color: AppColors.blue),
            ],
          ),
        ),
      ),
    );
  }
}
