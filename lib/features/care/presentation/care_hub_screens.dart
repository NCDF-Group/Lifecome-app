import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/feedback/status_chip.dart';
import '../../../core/widgets/layout/detail_list.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/layout/section_header.dart';
import '../../../core/widgets/lists/row_card.dart';
import '../../../core/widgets/lists/timeline_item.dart';
import '../../../core/widgets/media/lc_icons.dart';
import '../application/care_controller.dart';
import '../domain/care_models.dart';
import 'care_widgets.dart';

/// "Care that feels personal" — the Professional Care hub (screen pack 069).
class CareHubScreen extends ConsumerWidget {
  const CareHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final care = ref.watch(careProvider);
    final requested = care.request != null;

    return CarePage(
      backFallback: RoutePaths.home,
      children: [
        const ScreenTitle(
          eyebrow: 'Professional care',
          title: 'Care that feels personal',
          subtitle: 'Professional support, built around your everyday life.',
        ),
        const SizedBox(height: 14),
        if (!requested) ...[
          const PanelCard(
            title: 'Let’s understand what you need',
            body:
                'Start with a care request. A coordinator will discuss your '
                'needs and arrange an assessment.',
            tone: PanelTone.mint,
          ),
          const SizedBox(height: 6),
          PrimaryButton(
            label: 'Request care',
            onPressed: () => context.push(RoutePaths.careRequest),
          ),
        ] else
          PanelCard(
            title: care.accepted ? 'Your care plan is agreed' : 'Request sent',
            body: 'Reference ${care.request!.reference}',
            tone: PanelTone.mint,
            child: StatusBadge(
              care.accepted ? 'Care plan agreed' : 'Assessment requested',
              tone: BadgeTone.blue,
            ),
          ),
        const SizedBox(height: 4),
        RowCard(
          icon: LcIcons.care,
          title: 'Explore care services',
          subtitle: 'See the types of support available',
          onTap: () => context.push(RoutePaths.careServices),
        ),
        const SectionHeader(title: 'Your care'),
        RowCard(
          icon: LcIcons.clock,
          title: 'My care request',
          subtitle: 'Follow your assessment and next steps',
          onTap: () => context.push(RoutePaths.careStatus),
        ),
        RowCard(
          icon: LcIcons.file,
          title: 'My care plan',
          subtitle: 'Agreed support and preferences',
          onTap: () => context.push(RoutePaths.carePlan),
        ),
        RowCard(
          icon: LcIcons.calendar,
          title: 'Care visits',
          subtitle: 'Your upcoming visits and visit notes',
          tone: RowCardTone.mint,
          onTap: () => context.push(RoutePaths.careVisits),
        ),
        RowCard(
          icon: LcIcons.people,
          title: 'My care team',
          subtitle: 'The people supporting you',
          tone: RowCardTone.mint,
          onTap: () => context.push(RoutePaths.careTeam),
        ),
        const SizedBox(height: 10),
        const CarePreviewNotice(),
      ],
    );
  }
}

/// "Support for everyday life" — the care service catalogue (070).
class CareServicesScreen extends StatelessWidget {
  const CareServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CarePage(
      children: [
        const ScreenTitle(
          title: 'Support for everyday life',
          subtitle: 'Explore the kinds of care available.',
        ),
        const SizedBox(height: 14),
        for (final (i, service) in CareService.all.indexed)
          RowCard(
            icon: service.icon,
            title: service.title,
            subtitle: service.summary,
            tone: i.isEven ? RowCardTone.blue : RowCardTone.mint,
            onTap: () => context.push(RoutePaths.careService, extra: service),
          ),
        const SizedBox(height: 10),
        const CarePreviewNotice(),
      ],
    );
  }
}

/// One care service (071-074): what it is, how it starts, and the way in.
class CareServiceScreen extends StatelessWidget {
  const CareServiceScreen({super.key, required this.service});

  final CareService service;

  @override
  Widget build(BuildContext context) {
    return CarePage(
      backFallback: RoutePaths.careServices,
      children: [
        ScreenTitle(
          eyebrow: 'Professional care',
          title: service.title,
          subtitle: service.description,
        ),
        const SizedBox(height: 8),
        const SectionHeader(title: 'How it starts'),
        StepTimeline(
          active: 0,
          items: [
            for (final (i, step) in service.steps.indexed)
              (step, 'Step ${i + 1} with your care coordinator.'),
          ],
        ),
        PrimaryButton(
          label: 'Request this care',
          onPressed: () => context.push(RoutePaths.careRequest, extra: service),
        ),
      ],
    );
  }
}
