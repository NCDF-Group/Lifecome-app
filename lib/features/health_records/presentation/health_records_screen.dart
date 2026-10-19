import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/layout/section_header.dart';
import '../../../core/widgets/lists/row_card.dart';
import '../../../core/widgets/media/lc_icons.dart';
import '../application/health_records_controller.dart';
import 'records_list_screen.dart';

/// "Your health records" (screen pack 054): consultation notes,
/// prescriptions, referrals and results, each with how many there are.
/// With nothing shared yet it shows the pack's empty state (145) above the
/// sections.
class HealthRecordsScreen extends ConsumerWidget {
  const HealthRecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final counts = [
      ref.watch(clinicalNotesProvider).value?.length,
      ref.watch(prescriptionsProvider).value?.length,
      ref.watch(referralsProvider).value?.length,
      ref.watch(diagnosticResultsProvider).value?.length,
    ];
    final loaded = counts.every((count) => count != null);
    final empty = loaded && counts.every((count) => count == 0);

    String countLabel(int? count, String fallback) => switch (count) {
      null || 0 => fallback,
      1 => '1 record',
      final n => '$n records',
    };

    void open(RecordKind kind) =>
        context.push(RoutePaths.healthRecordsList, extra: kind);

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 25),
          children: [
            const AppHeaderBar(showBack: true),
            const SizedBox(height: 4),
            const ScreenTitle(
              title: 'Your health records',
              subtitle: 'Your information, easy to find.',
            ),
            if (empty) ...[
              const SizedBox(height: 24),
              Center(
                child: LcIcon(
                  LcIcons.file,
                  size: 48,
                  color: palette.accent.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your records will appear here',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                  color: palette.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'After a consultation, your care team can share notes, '
                'documents and next steps.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: palette.inkMuted,
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Explore GP services',
                onPressed: () => context.push(RoutePaths.gp),
              ),
              const SectionHeader(title: 'Your records'),
            ] else
              const SizedBox(height: 14),
            RowCard(
              icon: LcIcons.file,
              title: 'Consultation notes',
              subtitle: countLabel(counts[0], 'Your GP appointment summaries'),
              onTap: () => open(RecordKind.notes),
            ),
            RowCard(
              icon: LcIcons.plus,
              title: 'Prescriptions',
              subtitle: countLabel(
                counts[1],
                'Issued prescriptions and status',
              ),
              onTap: () => open(RecordKind.prescriptions),
            ),
            RowCard(
              icon: LcIcons.arrow,
              title: 'Referrals',
              subtitle: countLabel(
                counts[2],
                'Referral documents and next steps',
              ),
              onTap: () => open(RecordKind.referrals),
            ),
            RowCard(
              icon: LcIcons.file,
              title: 'Test results',
              subtitle: countLabel(
                counts[3],
                'Results shared by your clinician',
              ),
              onTap: () => open(RecordKind.results),
            ),
            RowCard(
              icon: LcIcons.leaf,
              title: 'Menopause care plan',
              subtitle: 'Your assessment and review journey',
              tone: RowCardTone.mint,
              onTap: () => context.push(RoutePaths.menopausePlan),
            ),
            const SectionHeader(title: 'Sharing'),
            RowCard(
              icon: LcIcons.people,
              title: 'Manage sharing permissions',
              subtitle: 'Choose who can view your records',
              tone: RowCardTone.white,
              onTap: () => context.push(RoutePaths.privacyAndSharing),
            ),
            RowCard(
              icon: LcIcons.download,
              title: 'Upload a document',
              subtitle: 'Share letters or results with your care team',
              tone: RowCardTone.white,
              onTap: () =>
                  showComingSoonPopup(context, feature: 'Document upload'),
            ),
            const SizedBox(height: 8),
            const InfoBanner(
              message:
                  'These records may not include your complete NHS history.',
            ),
          ],
        ),
      ),
    );
  }
}
