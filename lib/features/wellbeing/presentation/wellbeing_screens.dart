import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons/ghost_button.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/feedback/error_state.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/feedback/skeleton_loader.dart';
import '../../../core/widgets/layout/detail_list.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/layout/section_header.dart';
import '../../../core/widgets/lists/row_card.dart';
import '../../../core/widgets/media/avatar.dart';
import '../../../core/widgets/media/lc_icons.dart';
import '../../booking/application/booking_controller.dart';
import '../../booking/domain/models/availability_slot.dart';
import '../application/wellbeing_controller.dart';
import '../domain/wellbeing_models.dart';
import 'wellbeing_booking_screens.dart';
import 'wellbeing_widgets.dart';

/// Wellbeing hub, populated from the authenticated backend catalogue and sessions.
class WellbeingHubScreen extends ConsumerWidget {
  const WellbeingHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(wellbeingProvider);
    return WellbeingPage(
      backFallback: RoutePaths.home,
      children: data.when(
        loading: () => [
          const ScreenTitle(
            eyebrow: 'Wellbeing',
            title: 'Small steps.\nA healthier you.',
            subtitle: 'Practical support for everyday wellbeing.',
          ),
          const SkeletonLoader(),
        ],
        error: (error, _) => [
          ErrorState(
            error: error,
            onRetry: () => ref.read(wellbeingProvider.notifier).refresh(),
          ),
        ],
        data: (state) => [
          const ScreenTitle(
            eyebrow: 'Wellbeing',
            title: 'Small steps.\nA healthier you.',
            subtitle: 'Practical support for everyday wellbeing.',
          ),
          const SizedBox(height: 14),
          if (state.offers.isEmpty)
            const _WellbeingEmpty(message: 'No wellbeing services are available right now.'),
          for (final (index, offer) in state.offers.indexed)
            RowCard(
              icon: offer.icon,
              title: offer.title,
              subtitle: offer.summary,
              tone: index == 0 ? RowCardTone.mint : RowCardTone.blue,
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
            subtitle: state.plan?.goal ?? 'Your goals and next steps',
            onTap: () => context.push(RoutePaths.wellbeingPlan),
          ),
          RowCard(
            icon: LcIcons.calendar,
            title: 'My sessions',
            subtitle: _sessionSummary(state.latestSession),
            onTap: () => context.push(RoutePaths.wellbeingSession),
          ),
          const SizedBox(height: 10),
          const InfoBanner(
            message:
                'Wellbeing support complements clinical care. For a medical '
                'concern, choose GP services.',
          ),
        ],
      ),
    );
  }

  static String _sessionSummary(WellbeingSession? session) {
    if (session == null) return 'Your appointments and follow-ups';
    if (session.isCancelled) return 'Cancelled · ${session.offer.title}';
    return '${Formatters.shortDate(session.startsAt.toLocal())}, '
        '${Formatters.time(session.startsAt.toLocal())} · ${session.offer.title}';
  }
}

class _WellbeingEmpty extends StatelessWidget {
  const _WellbeingEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 18),
    child: Text(message, style: TextStyle(color: context.palette.inkMuted)),
  );
}

/// A service detail page whose descriptive fields and fee come from the API.
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
        DetailList(
          rows: [
            ('Format', 'Online'),
            ('Duration', '${offer.durationMinutes} minutes'),
            ('Fee', Formatters.money(offer.pricePence)),
          ],
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'Find an available practitioner',
          onPressed: () =>
              context.push(RoutePaths.wellbeingPractitioner, extra: offer),
        ),
        if (offer.sessionType == 'stress_management') ...[
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

/// Lists active practitioners from the directory and checks each one's live slots.
class WellbeingPractitionerScreen extends ConsumerWidget {
  const WellbeingPractitionerScreen({super.key, required this.offer});

  final WellbeingOffer offer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final practitioners = ref.watch(wellbeingPractitionersProvider);
    return WellbeingPage(
      children: [
        const ScreenTitle(
          title: 'Available practitioners',
          subtitle: 'Availability is updated from the live schedule.',
        ),
        const SizedBox(height: 12),
        practitioners.when(
          loading: () => const SkeletonLoader(),
          error: (error, _) => ErrorState(
            error: error,
            onRetry: () => ref.invalidate(wellbeingPractitionersProvider),
          ),
          data: (items) {
            if (items.isEmpty) {
              return const _WellbeingEmpty(
                message: 'No wellbeing practitioners are listed right now.',
              );
            }
            return Column(
              children: [
                for (final practitioner in items)
                  _WellbeingPractitionerCard(
                    offer: offer,
                    practitioner: practitioner,
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _WellbeingPractitionerCard extends ConsumerWidget {
  const _WellbeingPractitionerCard({
    required this.offer,
    required this.practitioner,
  });

  final WellbeingOffer offer;
  final Doctor practitioner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availability = ref.watch(availabilityProvider(practitioner.id));
    final palette = context.palette;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.elevated,
        border: Border.all(color: palette.line),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          UserAvatar(name: practitioner.name, radius: 23),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  practitioner.name,
                  style: TextStyle(fontWeight: FontWeight.w700, color: palette.ink),
                ),
                Text(
                  practitioner.specialty,
                  style: TextStyle(fontSize: 12.5, color: palette.inkMuted),
                ),
                availability.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: SkeletonLoader.inlineChips(padding: 0),
                  ),
                  error: (_, _) => Text(
                    "Couldn't load availability",
                    style: TextStyle(fontSize: 12, color: palette.danger),
                  ),
                  data: (slots) => Text(
                    slots.isEmpty
                        ? 'No available times'
                        : '${slots.length} available time${slots.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: slots.isEmpty ? palette.inkMuted : palette.positive,
                    ),
                  ),
                ),
              ],
            ),
          ),
          availability.maybeWhen(
            data: (slots) => IconButton(
              tooltip: slots.isEmpty ? 'No available times' : 'Choose a time',
              onPressed: slots.isEmpty
                  ? null
                  : () => context.push(
                      RoutePaths.wellbeingSlots,
                      extra: WellbeingPractitionerSelection(
                        offer: offer,
                        practitioner: practitioner,
                      ),
                    ),
              icon: Icon(Icons.chevron_right, color: palette.accent),
            ),
            orElse: () => const SizedBox(width: 40),
          ),
        ],
      ),
    );
  }
}
