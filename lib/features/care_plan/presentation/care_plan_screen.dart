import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/buttons/secondary_button.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/feedback/status_chip.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/detail_list.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/lists/row_card.dart';
import '../../../core/widgets/lists/timeline_item.dart';
import '../../../core/widgets/media/lc_icons.dart';
import '../../booking/domain/models/appointment.dart';

/// "Your GP care plan" (screen pack 052-053), shown once a consultation
/// ends. Reachable directly too (with no visit, in which case [appointment]
/// is null and this shows an empty state).
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
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 25),
          children: [
            const AppHeaderBar(showBack: true, backFallback: RoutePaths.gp),
            if (visit == null) ...[
              const SizedBox(height: 30),
              Center(
                child: LcIcon(
                  LcIcons.file,
                  size: 48,
                  color: palette.accent.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'No care plan yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                  color: palette.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your care plan appears here once you complete a consultation.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: palette.inkMuted,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Book a GP appointment',
                onPressed: () => context.push(RoutePaths.gp),
              ),
            ] else ...[
              const SizedBox(height: 4),
              const ScreenTitle(
                title: 'Your GP care plan',
                subtitle: 'A clear view of your next steps.',
              ),
              const SizedBox(height: 12),
              const StatusBadge('Completed'),
              const SizedBox(height: 6),
              DetailList(
                rows: [
                  ('Service', visit.serviceName),
                  ('Clinician', visit.providerName),
                  (
                    'Date',
                    Formatters.longDate(Formatters.ukTime(visit.startsAt)),
                  ),
                ],
              ),
              const StepTimeline(
                items: [
                  ('Consultation complete', 'Your appointment has finished.'),
                  (
                    'Review your notes',
                    'Your clinician writes up what you discussed.',
                  ),
                  (
                    'Follow-up if agreed',
                    'Arrange another appointment when appropriate.',
                  ),
                ],
              ),
              const InfoBanner(
                title: "Your written plan isn't in the app yet",
                message:
                    'Visit summaries, agreed actions and prescriptions are '
                    'not shown in the app yet. Message your care team if you '
                    'need yours.',
              ),
              const SizedBox(height: 4),
              RowCard(
                icon: LcIcons.file,
                title: 'Health records',
                subtitle: 'Notes, prescriptions, referrals and results',
                onTap: () => context.go(RoutePaths.healthRecords),
              ),
              const SizedBox(height: 10),
              PrimaryButton(
                label: 'Book a follow-up',
                onPressed: () => context.push(RoutePaths.gp),
              ),
              const SizedBox(height: 10),
              SecondaryButton(
                label: 'Message care team',
                onPressed: () => context.go(RoutePaths.messages),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
