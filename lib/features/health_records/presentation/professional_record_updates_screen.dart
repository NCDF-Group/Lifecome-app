import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/feedback/error_state.dart';
import '../../../core/widgets/feedback/skeleton_loader.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/lists/row_card.dart';
import '../../../core/widgets/media/lc_icons.dart';
import '../application/health_records_controller.dart';

/// Signed clinical notes shared by clinicians through the backend.
class ProfessionalRecordUpdatesScreen extends ConsumerWidget {
  const ProfessionalRecordUpdatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(clinicalNotesProvider);
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
            const ScreenTitle(
              eyebrow: 'Health records',
              title: 'Professional record updates',
              subtitle:
                  'Clinical notes shared by your healthcare professionals.',
            ),
            const SizedBox(height: 12),
            notes.when(
              loading: () => const SkeletonLoader(),
              error: (error, _) => ErrorState(
                error: error,
                onRetry: () => ref.invalidate(clinicalNotesProvider),
              ),
              data: (items) => items.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'No professional notes have been shared with you yet.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: context.palette.inkMuted),
                      ),
                    )
                  : Column(
                      children: [
                        for (final item in items)
                          RowCard(
                            icon: LcIcons.file,
                            title: item.title,
                            subtitle:
                                '${item.clinician} · ${Formatters.date(item.date)}',
                            onTap: () => context.push(
                              RoutePaths.clinicalNote,
                              extra: item,
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
