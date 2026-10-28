import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/feedback/recovery_view.dart';
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
            if (empty)
              RecoveryView(
                icon: LcIcons.file,
                title: 'No records yet.',
                message:
                    'Your health records will appear here after your care '
                    'team shares them.',
                details: [
                  _ShortcutGrid(
                    shortcuts: [
                      (
                        LcIcons.file,
                        'Consultation notes',
                        () => open(RecordKind.notes),
                        true,
                      ),
                      (
                        LcIcons.plus,
                        'Prescriptions',
                        () => open(RecordKind.prescriptions),
                        false,
                      ),
                      (
                        LcIcons.arrow,
                        'Referrals',
                        () => open(RecordKind.referrals),
                        false,
                      ),
                      (
                        LcIcons.leaf,
                        'Results',
                        () => open(RecordKind.results),
                        true,
                      ),
                    ],
                  ),
                ],
                primaryLabel: 'Explore GP services',
                primaryIcon: LcIcons.calendar,
                onPrimary: () => context.push(RoutePaths.gp),
                secondaryLabel: 'Back to home',
                secondaryIcon: LcIcons.back,
                onSecondary: () => context.go(RoutePaths.home),
              )
            else ...[
              const SizedBox(height: 4),
              const ScreenTitle(
                title: 'Your health records',
                subtitle: 'Your information, easy to find.',
              ),
              const SizedBox(height: 14),
            ],
            if (!empty) ...[
              RowCard(
                icon: LcIcons.file,
                title: 'Consultation notes',
                subtitle: countLabel(
                  counts[0],
                  'Your GP appointment summaries',
                ),
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
            ],
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

/// The four record shortcuts under the empty state: a 2 x 2 grid of tinted
/// tiles, each an icon, a name and a chevron.
class _ShortcutGrid extends StatelessWidget {
  const _ShortcutGrid({required this.shortcuts});

  /// (icon, label, onTap, green) — green tiles use the mint tint.
  final List<(String, String, VoidCallback, bool)> shortcuts;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    Widget tile((String, String, VoidCallback, bool) item) {
      final (icon, label, onTap, green) = item;
      final tint = green ? palette.tintGreen : palette.tintBlueFaint;
      final strong = green ? palette.tintGreenStrong : palette.tintBlue;
      final ink = green ? palette.positive : palette.accent;
      return Expanded(
        child: Material(
          color: tint,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: strong,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: LcIcon(icon, size: 20, color: ink),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: palette.ink,
                      ),
                    ),
                  ),
                  LcIcon(LcIcons.chevron, size: 16, color: ink),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            tile(shortcuts[0]),
            const SizedBox(width: 10),
            tile(shortcuts[1]),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            tile(shortcuts[2]),
            const SizedBox(width: 10),
            tile(shortcuts[3]),
          ],
        ),
      ],
    );
  }
}
