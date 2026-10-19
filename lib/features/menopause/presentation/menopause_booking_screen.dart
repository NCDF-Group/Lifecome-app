import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/lists/row_card.dart';
import '../../../core/widgets/media/lc_icons.dart';
import '../../booking/domain/models/booking_selection.dart';
import '../../booking/domain/models/consultation_mode.dart';
import '../application/menopause_controller.dart';

/// "Choose your appointment" for Menopause Care (screen pack 066). Both
/// options continue into the shared GP booking at the eligibility step.
class MenopauseBookingScreen extends ConsumerWidget {
  const MenopauseBookingScreen({super.key});

  void _book(BuildContext context, ConsultationMode mode) => context.push(
    RoutePaths.gpEligibility,
    extra: BookingStart.direct(mode: mode),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assessed = ref.watch(menopauseProvider).assessment != null;

    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 25),
          children: [
            const AppHeaderBar(
              showBack: true,
              backFallback: RoutePaths.menopause,
            ),
            const SizedBox(height: 4),
            ScreenTitle(
              title: 'Choose your appointment',
              subtitle: assessed
                  ? 'Your assessment will be available to the GP.'
                  : 'You can complete the assessment first to help your GP '
                        'prepare.',
            ),
            const SizedBox(height: 14),
            RowCard(
              icon: LcIcons.video,
              title: 'Online menopause consultation',
              subtitle: 'Meet your GP by video',
              onTap: () => _book(context, ConsultationMode.video),
            ),
            RowCard(
              icon: LcIcons.clinic,
              title: 'In-clinic menopause consultation',
              subtitle: 'Visit a GP in person',
              tone: RowCardTone.mint,
              onTap: () => _book(context, ConsultationMode.inPerson),
            ),
            if (!assessed)
              RowCard(
                icon: LcIcons.file,
                title: 'Start your assessment',
                subtitle: 'A few questions before your consultation',
                tone: RowCardTone.white,
                onTap: () => context.push(RoutePaths.menopauseAssessment),
              ),
            const SizedBox(height: 8),
            const InfoBanner(
              message:
                  'Choose the closest reason when you book. Prices are shown '
                  'before you confirm.',
            ),
          ],
        ),
      ),
    );
  }
}
