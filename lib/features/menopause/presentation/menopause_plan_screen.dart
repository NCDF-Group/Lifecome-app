import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/buttons/secondary_button.dart';
import '../../../core/widgets/feedback/status_chip.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/detail_list.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/lists/timeline_item.dart';
import '../application/menopause_controller.dart';

/// "Your menopause care plan" (screen pack 067): where the person is in
/// assessment, consultation and review. Clinical options, including HRT,
/// appear here only once a clinician has recorded them — none are suggested
/// by the app.
class MenopausePlanScreen extends ConsumerWidget {
  const MenopausePlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(menopauseProvider);
    final assessed = state.assessment != null;

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
            const ScreenTitle(
              title: 'Your menopause care plan',
              subtitle: 'Support that continues beyond your appointment.',
            ),
            const SizedBox(height: 12),
            StatusBadge(
              assessed ? 'Assessment saved' : 'Not started',
              tone: assessed ? BadgeTone.green : BadgeTone.gray,
            ),
            StepTimeline(
              active: assessed ? 1 : 0,
              items: const [
                ('Assessment', 'Your priorities and history are recorded.'),
                (
                  'GP consultation',
                  'Discuss symptoms and care options with your GP.',
                ),
                (
                  'Ongoing review',
                  'Review your experience and any agreed treatment.',
                ),
              ],
            ),
            const PanelCard(
              title: 'Treatment and HRT',
              body:
                  'Your clinician will record any agreed options here after '
                  'your assessment and consultation.',
            ),
            if (state.review != null)
              PanelCard(
                title: 'Your next review',
                tone: PanelTone.blue,
                child: DetailList(
                  rows: [
                    ('How things have been', state.review!.progress),
                    ('To review', state.review!.review),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            PrimaryButton(
              label: assessed ? 'Book a review' : 'Start your assessment',
              onPressed: () => context.push(
                assessed
                    ? RoutePaths.menopauseReview
                    : RoutePaths.menopauseAssessment,
              ),
            ),
            const SizedBox(height: 10),
            SecondaryButton(
              label: 'Message the GP team',
              onPressed: () => context.go(RoutePaths.messages),
            ),
          ],
        ),
      ),
    );
  }
}
