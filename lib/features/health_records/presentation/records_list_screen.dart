import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/feedback/error_state.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/feedback/loading_indicator.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/lists/row_card.dart';
import '../../../core/widgets/media/lc_icons.dart';
import '../application/health_records_controller.dart';

/// The four kinds of record the records hub lists.
enum RecordKind { notes, prescriptions, referrals, results }

/// One record list (screen pack 056, 058, 060, and consultation notes):
/// each record as a row that opens its detail, or an honest empty state.
class RecordsListScreen extends ConsumerWidget {
  const RecordsListScreen({super.key, required this.kind});

  final RecordKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (title, subtitle, emptyText, note) = switch (kind) {
      RecordKind.notes => (
        'Consultation notes',
        'Summaries written by your clinician after each appointment.',
        'No consultation notes have been shared with you yet.',
        null,
      ),
      RecordKind.prescriptions => (
        'Your prescriptions',
        'Prescriptions appear after review by a clinician.',
        'You have no prescriptions.',
        'Booking a consultation does not guarantee a prescription.',
      ),
      RecordKind.referrals => (
        'Your referrals',
        'Keep track of your next steps.',
        'You have no referrals.',
        null,
      ),
      RecordKind.results => (
        'Your test results',
        'Results shared with you by your care team.',
        'No test results have been shared with you yet.',
        'Your clinician will explain results and any recommended next steps.',
      ),
    };

    final rows = switch (kind) {
      RecordKind.notes =>
        ref
            .watch(clinicalNotesProvider)
            .whenData(
              (list) => [
                for (final item in list)
                  RowCard(
                    icon: LcIcons.file,
                    title: item.title,
                    subtitle:
                        '${item.clinician} · ${Formatters.date(item.date)}',
                    onTap: () =>
                        context.push(RoutePaths.clinicalNote, extra: item),
                  ),
              ],
            ),
      RecordKind.prescriptions =>
        ref
            .watch(prescriptionsProvider)
            .whenData(
              (list) => [
                for (final item in list)
                  RowCard(
                    icon: LcIcons.plus,
                    title: item.medicine ?? 'Prescription ${item.reference}',
                    subtitle:
                        '${item.status} · ${Formatters.date(item.issuedOn)}',
                    onTap: () =>
                        context.push(RoutePaths.prescription, extra: item),
                  ),
              ],
            ),
      RecordKind.referrals =>
        ref
            .watch(referralsProvider)
            .whenData(
              (list) => [
                for (final item in list)
                  RowCard(
                    icon: LcIcons.arrow,
                    title: item.specialty,
                    subtitle: item.status,
                    onTap: () => context.push(RoutePaths.referral, extra: item),
                  ),
              ],
            ),
      RecordKind.results =>
        ref
            .watch(diagnosticResultsProvider)
            .whenData(
              (list) => [
                for (final item in list)
                  RowCard(
                    icon: LcIcons.file,
                    title: item.title,
                    subtitle: 'Reviewed · ${Formatters.date(item.date)}',
                    onTap: () =>
                        context.push(RoutePaths.diagnosticResult, extra: item),
                  ),
              ],
            ),
    };

    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 25),
          children: [
            const AppHeaderBar(
              showBack: true,
              backFallback: RoutePaths.healthRecords,
            ),
            const SizedBox(height: 4),
            ScreenTitle(title: title, subtitle: subtitle),
            const SizedBox(height: 14),
            rows.when(
              loading: () => const LoadingIndicator(),
              error: (error, _) => ErrorState(
                error: error,
                onRetry: () => ref.invalidate(switch (kind) {
                  RecordKind.notes => clinicalNotesProvider,
                  RecordKind.prescriptions => prescriptionsProvider,
                  RecordKind.referrals => referralsProvider,
                  RecordKind.results => diagnosticResultsProvider,
                }),
              ),
              data: (cards) => cards.isEmpty
                  ? _Empty(text: emptyText)
                  : Column(children: cards),
            ),
            if (note != null) ...[
              const SizedBox(height: 8),
              InfoBanner(message: note),
            ],
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border.all(color: palette.line),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        children: [
          LcIcon(LcIcons.file, size: 36, color: palette.accent),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: palette.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}
