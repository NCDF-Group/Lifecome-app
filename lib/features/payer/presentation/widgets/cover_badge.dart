import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../application/payer_controller.dart';
import '../../domain/models/eligibility_status.dart';

/// A health plan's answer for one service, as a small pill: covered, co-pay,
/// needs authorisation, not covered — or that it could not be checked.
class CoverBadge extends StatelessWidget {
  const CoverBadge({super.key, required this.loading, required this.coverage});

  final bool loading;
  final ServiceCoverage? coverage;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final check = coverage?.check;

    final (label, color) = loading
        ? ('Checking your cover…', palette.inkMuted)
        : check == null
        ? ("Couldn't check your cover", palette.danger)
        : switch (check.status) {
            EligibilityStatus.covered => ('Covered', palette.positive),
            EligibilityStatus.coPay => (
              check.coPayMinor == null
                  ? 'Co-pay applies'
                  : 'Co-pay ${Formatters.money(check.coPayMinor!)}',
              palette.warning,
            ),
            EligibilityStatus.preAuthorisationRequired => (
              'Requires authorisation',
              palette.warning,
            ),
            final other => (other.label, palette.danger),
          };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
