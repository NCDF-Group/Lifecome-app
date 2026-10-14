import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../booking/domain/models/appointment.dart';

/// Blueprint view 20 — Care Plan & Visit Summary, shown once a consultation
/// ends. Reachable directly too (with no visit, in which case [appointment] is
/// null and this shows an empty state).
///
/// The backend has no patient-facing care plan or visit summary yet, so this
/// shows what is known — the visit has finished — and says plainly that the
/// written plan is not available in the app, rather than inventing one.
class CarePlanScreen extends StatelessWidget {
  const CarePlanScreen({super.key, this.appointment});

  final Appointment? appointment;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final visit = appointment;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const AppHeaderBar(showBack: true),
            const SizedBox(height: 20),
            if (visit == null) ...[
              const SizedBox(height: AppSpacing.xl),
              Center(
                child: Container(
                  width: 84,
                  height: 84,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    color: palette.accent,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'No care plan yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: palette.ink,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Your care plan appears here once you complete a consultation.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: palette.inkMuted,
                  height: 1.4,
                ),
              ),
            ] else ...[
              const ScreenTitle(title: 'Your care plan'),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: palette.tintGreen,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: palette.elevated,
                      child: Icon(
                        Icons.check,
                        color: palette.positive,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            visit.serviceName,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: palette.ink,
                            ),
                          ),
                          Text(
                            'with ${visit.providerName}',
                            style: TextStyle(
                              fontSize: 13,
                              color: palette.inkMuted,
                            ),
                          ),
                          Text(
                            Formatters.longDate(
                              Formatters.ukTime(visit.startsAt),
                            ),
                            style: TextStyle(
                              fontSize: 13,
                              color: palette.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const InfoBanner(
                title: "Your written plan isn't in the app yet",
                message:
                    'Visit summaries, agreed actions and prescriptions are '
                    "not shown in the app yet. Message your care team if you "
                    'need yours.',
              ),
              const SizedBox(height: AppSpacing.md),
              PrimaryButton(
                label: 'Message care team',
                icon: Icons.forum_outlined,
                onPressed: () => context.go(RoutePaths.messages),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
