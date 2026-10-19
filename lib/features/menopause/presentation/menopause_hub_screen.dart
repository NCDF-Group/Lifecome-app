import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/feedback/status_chip.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/detail_list.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/lists/row_card.dart';
import '../../../core/widgets/media/lc_icons.dart';
import '../application/menopause_controller.dart';

/// Menopause Care (screen pack 062), part of GP: start with the assessment,
/// then book a consultation; the care plan and reviews follow.
class MenopauseHubScreen extends ConsumerWidget {
  const MenopauseHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assessment = ref.watch(menopauseProvider).assessment;

    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 25),
          children: [
            const AppHeaderBar(showBack: true, backFallback: RoutePaths.gp),
            const SizedBox(height: 4),
            const ScreenTitle(
              eyebrow: 'GP · Menopause Care',
              title: 'Support through menopause',
              subtitle:
                  'Personal care for your symptoms, questions and next steps.',
            ),
            const SizedBox(height: 14),
            if (assessment == null) ...[
              const PanelCard(
                title: 'Start with a conversation',
                body:
                    'Complete a short assessment, then book time with a GP to '
                    'discuss your needs.',
                tone: PanelTone.mint,
              ),
              const SizedBox(height: 6),
              PrimaryButton(
                label: 'Start your assessment',
                onPressed: () => context.push(RoutePaths.menopauseAssessment),
              ),
            ] else ...[
              PanelCard(
                title: 'Your assessment is ready',
                body: 'Your GP will see it before your consultation.',
                tone: PanelTone.mint,
                child: const StatusBadge('Saved'),
              ),
              const SizedBox(height: 6),
              PrimaryButton(
                label: 'Choose an appointment',
                onPressed: () => context.push(RoutePaths.menopauseBooking),
              ),
            ],
            const SizedBox(height: 6),
            RowCard(
              icon: LcIcons.video,
              title: 'Book a menopause consultation',
              subtitle: 'Online or in-clinic GP support',
              onTap: () => context.push(RoutePaths.menopauseBooking),
            ),
            RowCard(
              icon: LcIcons.leaf,
              title: 'My menopause care plan',
              subtitle: 'Your agreed plan and ongoing reviews',
              tone: RowCardTone.mint,
              onTap: () => context.push(RoutePaths.menopausePlan),
            ),
            RowCard(
              icon: LcIcons.calendar,
              title: 'Book a review',
              subtitle: 'Continue your care with the team',
              onTap: () => context.push(RoutePaths.menopauseReview),
            ),
            if (assessment != null)
              RowCard(
                icon: LcIcons.file,
                title: 'Update your assessment',
                subtitle: assessment.topic,
                tone: RowCardTone.white,
                onTap: () => context.push(RoutePaths.menopauseAssessment),
              ),
            const SizedBox(height: 8),
            const InfoBanner(
              message:
                  'Treatment, including HRT where appropriate, follows an '
                  'individual clinical assessment. A prescription is not '
                  'guaranteed.',
            ),
          ],
        ),
      ),
    );
  }
}
