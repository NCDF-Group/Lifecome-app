import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons/ghost_button.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/layout/detail_list.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/layout/section_header.dart';
import '../../../core/widgets/lists/row_card.dart';
import '../../../core/widgets/lists/timeline_item.dart';
import '../../../core/widgets/media/avatar.dart';
import '../../../core/widgets/media/lc_icons.dart';
import '../application/wellbeing_controller.dart';
import '../domain/wellbeing_models.dart';
import 'wellbeing_widgets.dart';

/// "Small steps. A healthier you." — the Wellbeing hub (screen pack 091).
class WellbeingHubScreen extends ConsumerWidget {
  const WellbeingHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wellbeingProvider);
    final session = state.session;

    return WellbeingPage(
      backFallback: RoutePaths.home,
      children: [
        const ScreenTitle(
          eyebrow: 'Wellbeing',
          title: 'Small steps.\nA healthier you.',
          subtitle: 'Practical support for everyday wellbeing.',
        ),
        const SizedBox(height: 14),
        for (final (i, offer) in WellbeingOffer.all.indexed)
          RowCard(
            icon: offer.icon,
            title: offer.title,
            subtitle: offer.summary,
            tone: i == 0 ? RowCardTone.mint : RowCardTone.blue,
            onTap: () => context.push(RoutePaths.wellbeingOffer, extra: offer),
          ),
        RowCard(
          icon: LcIcons.bag,
          title: 'Wellbeing Shop',
          subtitle: 'Products for your everyday routine',
          tone: RowCardTone.mint,
          onTap: () => context.push(RoutePaths.shop),
        ),
        const SectionHeader(title: 'Your wellbeing'),
        RowCard(
          icon: LcIcons.file,
          title: 'My wellbeing plan',
          subtitle: 'Your goals and next steps',
          onTap: () => context.push(RoutePaths.wellbeingPlan),
        ),
        RowCard(
          icon: LcIcons.calendar,
          title: 'My sessions',
          subtitle: session == null
              ? 'Your appointments and follow-ups'
              : session.cancelled
              ? 'Cancelled · ${session.offer.title}'
              : '${Formatters.shortDate(session.startsAt)}, '
                    '${Formatters.time(session.startsAt)} · '
                    '${session.offer.title}',
          onTap: () => context.push(RoutePaths.wellbeingSession),
        ),
        const SizedBox(height: 10),
        const InfoBanner(
          message:
              'Wellbeing support complements clinical care. For a medical '
              'concern, choose GP services.',
        ),
        const SizedBox(height: 10),
        const WellbeingPreviewNotice(),
      ],
    );
  }
}

/// One wellbeing offer (screen pack 092-094).
class WellbeingOfferScreen extends StatelessWidget {
  const WellbeingOfferScreen({super.key, required this.offer});

  final WellbeingOffer offer;

  @override
  Widget build(BuildContext context) {
    return WellbeingPage(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: context.palette.tintGreen,
              child: Image.asset(offer.heroImage, fit: BoxFit.cover),
            ),
          ),
        ),
        const SizedBox(height: 18),
        ScreenTitle(
          eyebrow: 'Wellbeing',
          title: offer.title,
          subtitle: offer.description,
        ),
        const SectionHeader(title: 'What to expect'),
        StepTimeline(
          active: 0,
          items: [
            for (final (i, step) in offer.steps.indexed)
              (step, 'Part ${i + 1} of your session.'),
          ],
        ),
        DetailList(
          rows: [
            ('Format', 'Online'),
            ('Duration', '${WellbeingOffer.durationMinutes} minutes'),
            ('Example fee', Formatters.money(offer.pricePence)),
          ],
        ),
        if (offer.note != null) ...[
          const SizedBox(height: 10),
          InfoBanner(message: offer.note!),
        ],
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'Meet your practitioner',
          onPressed: () =>
              context.push(RoutePaths.wellbeingPractitioner, extra: offer),
        ),
        if (offer.id == 'stress') ...[
          const SizedBox(height: 6),
          GhostButton(
            label: 'Need urgent help?',
            color: context.palette.danger,
            onPressed: () => context.push(RoutePaths.emergency),
          ),
        ],
      ],
    );
  }
}

/// "Meet your practitioner" (screen pack 095).
class WellbeingPractitionerScreen extends StatelessWidget {
  const WellbeingPractitionerScreen({super.key, required this.offer});

  final WellbeingOffer offer;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return WellbeingPage(
      children: [
        const ScreenTitle(
          title: 'Meet your practitioner',
          subtitle: 'A supportive conversation, at your pace.',
        ),
        const SizedBox(height: 16),
        Center(child: UserAvatar(name: WellbeingPractitioner.name, radius: 39)),
        const SizedBox(height: 12),
        Text(
          WellbeingPractitioner.name,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: palette.ink,
          ),
        ),
        Text(
          WellbeingPractitioner.role,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13.5, color: palette.inkMuted),
        ),
        const SizedBox(height: 12),
        const PanelCard(
          title: 'About Jordan',
          body:
              'An example profile. Verified experience, the support they '
              'offer and the languages they speak will appear here.',
          tone: PanelTone.mint,
        ),
        DetailList(
          rows: [
            ('Session', offer.title),
            ('Format', 'Online'),
            ('Duration', '${WellbeingOffer.durationMinutes} minutes'),
            ('Example fee', Formatters.money(offer.pricePence)),
          ],
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'Choose a time',
          onPressed: () =>
              context.push(RoutePaths.wellbeingSlots, extra: offer),
        ),
      ],
    );
  }
}
