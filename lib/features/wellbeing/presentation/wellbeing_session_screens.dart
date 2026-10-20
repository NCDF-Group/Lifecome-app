import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/router/safe_back.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/buttons/ghost_button.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/buttons/secondary_button.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/feedback/status_chip.dart';
import '../../../core/widgets/inputs/choice_card.dart';
import '../../../core/widgets/inputs/form_fields.dart';
import '../../../core/widgets/layout/detail_list.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/lists/row_card.dart';
import '../../../core/widgets/lists/timeline_item.dart';
import '../../../core/widgets/media/lc_icons.dart';
import '../../consultation/presentation/widgets/video_stage.dart';
import '../application/wellbeing_controller.dart';
import '../domain/wellbeing_models.dart';
import 'wellbeing_booking_screens.dart';
import 'wellbeing_widgets.dart';

/// Shown when there is no session to act on.
class _NoSession extends StatelessWidget {
  const _NoSession();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 18),
        Center(
          child: LcIcon(LcIcons.calendar, size: 44, color: palette.accent),
        ),
        const SizedBox(height: 12),
        Text(
          'No wellbeing session booked',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: palette.ink,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Choose coaching, healthy eating or stress and relaxation support.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, height: 1.6, color: palette.inkMuted),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'Explore wellbeing',
          onPressed: () => context.goBack(fallback: RoutePaths.wellbeing),
        ),
      ],
    );
  }
}

/// "Your wellbeing session" (screen pack 099).
class WellbeingSessionScreen extends ConsumerWidget {
  const WellbeingSessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(wellbeingProvider).session;
    return WellbeingPage(
      children: [
        ScreenTitle(
          title: 'Your wellbeing session',
          subtitle: session == null ? null : 'Reference ${session.reference}',
        ),
        if (session == null)
          const _NoSession()
        else ...[
          const SizedBox(height: 12),
          session.cancelled
              ? const StatusBadge('Cancelled', tone: BadgeTone.gray)
              : const StatusBadge('Confirmed'),
          DetailList(rows: wellbeingDetails(session.offer, session.startsAt)),
          const SizedBox(height: 14),
          if (session.cancelled)
            PrimaryButton(
              label: 'Book another session',
              onPressed: () => context.goBack(fallback: RoutePaths.wellbeing),
            )
          else ...[
            PrimaryButton(
              label: 'Join session',
              onPressed: () => context.push(RoutePaths.wellbeingCall),
            ),
            const SizedBox(height: 10),
            SecondaryButton(
              label: 'Reschedule session',
              onPressed: () => context.push(RoutePaths.wellbeingSlots),
            ),
            const SizedBox(height: 4),
            GhostButton(
              label: 'Cancel session',
              onPressed: () => context.push(RoutePaths.wellbeingCancel),
            ),
          ],
          const SizedBox(height: 6),
          RowCard(
            icon: LcIcons.message,
            title: 'Message your practitioner',
            subtitle: 'Share a question before your session',
            onTap: () => context.push(RoutePaths.newMessage),
          ),
        ],
        const SizedBox(height: 10),
        const WellbeingPreviewNotice(),
      ],
    );
  }
}

/// "Cancel your session?" (screen pack 101): explicit confirmation.
class WellbeingCancelScreen extends ConsumerStatefulWidget {
  const WellbeingCancelScreen({super.key});

  @override
  ConsumerState<WellbeingCancelScreen> createState() =>
      _WellbeingCancelScreenState();
}

class _WellbeingCancelScreenState extends ConsumerState<WellbeingCancelScreen> {
  static const _reasons = [
    'Plans changed',
    'No longer needed',
    'Choose another service',
  ];
  String _reason = _reasons.first;
  bool _sure = false;
  bool _showError = false;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(wellbeingProvider).session;
    return WellbeingPage(
      backFallback: RoutePaths.wellbeingSession,
      children: [
        const ScreenTitle(
          title: 'Cancel your session?',
          subtitle: 'Please confirm you want to cancel this booking.',
        ),
        if (session == null)
          const _NoSession()
        else ...[
          const SizedBox(height: 10),
          DetailList(rows: wellbeingDetails(session.offer, session.startsAt)),
          const SizedBox(height: 8),
          const InfoBanner(
            tone: BannerTone.warning,
            message:
                'No payment was taken for this preview booking, so there is '
                'nothing to refund.',
          ),
          SelectField(
            label: 'Reason',
            options: _reasons,
            value: _reason,
            onChanged: (v) => setState(() => _reason = v),
          ),
          CheckRow(
            value: _sure,
            onChanged: (v) => setState(() {
              _sure = v;
              if (v) _showError = false;
            }),
            label: 'I want to cancel this session.',
          ),
          if (_showError)
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Text(
                'Please confirm to continue.',
                style: TextStyle(fontSize: 12.5, color: context.palette.danger),
              ),
            ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Confirm cancellation',
            onPressed: () {
              if (!_sure) {
                setState(() => _showError = true);
                return;
              }
              ref.read(wellbeingProvider.notifier).cancel(_reason);
              context.goBack(fallback: RoutePaths.wellbeingSession);
            },
          ),
        ],
      ],
    );
  }
}

/// The online session (screen pack 102). In-app video isn't available yet,
/// so this says so rather than pretending to connect.
class WellbeingCallScreen extends ConsumerWidget {
  const WellbeingCallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(wellbeingProvider).session;
    return WellbeingPage(
      backFallback: RoutePaths.wellbeingSession,
      children: [
        const ScreenTitle(title: 'Your wellbeing session', subtitle: 'Online'),
        const SizedBox(height: 16),
        VideoStage(
          name: WellbeingPractitioner.name,
          title: WellbeingPractitioner.name,
          message: session?.offer.title ?? 'Wellbeing session',
        ),
        const SizedBox(height: 14),
        const InfoBanner(
          message:
              "In-app video isn't available yet. Your practitioner will "
              'contact you to start the session.',
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'Finish and view my plan',
          onPressed: () => context.pushReplacement(RoutePaths.wellbeingPlan),
        ),
      ],
    );
  }
}

/// "Your wellbeing plan" (screen pack 103).
class WellbeingPlanScreen extends ConsumerWidget {
  const WellbeingPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wellbeingProvider);
    final goal = state.session?.goal;
    final latest = state.latestCheckIn;
    return WellbeingPage(
      children: [
        const ScreenTitle(
          title: 'Your wellbeing plan',
          subtitle: 'Small, practical steps for your week.',
        ),
        const SizedBox(height: 10),
        PanelCard(
          title: 'Your focus',
          body: goal ?? 'Book a session and tell your practitioner your goal.',
          tone: PanelTone.mint,
        ),
        const CheckList(
          items: [
            'Choose one manageable daily habit',
            'Make time to reflect on your week',
            'Discuss progress at your next session',
          ],
        ),
        RowCard(
          icon: LcIcons.star,
          title: 'My weekly check-in',
          subtitle: latest == null
              ? 'Record how your routine is going'
              : '${latest.score} of 5 · latest check-in',
          tone: RowCardTone.mint,
          onTap: () => context.push(RoutePaths.wellbeingCheckIn),
        ),
        const SizedBox(height: 10),
        PrimaryButton(
          label: 'Book your next session',
          onPressed: () {
            context.go(RoutePaths.home);
            context.push(RoutePaths.wellbeing);
          },
        ),
        const SizedBox(height: 10),
        SecondaryButton(
          label: 'Message your practitioner',
          onPressed: () => context.push(RoutePaths.newMessage),
        ),
      ],
    );
  }
}

/// "How is your week going?" (screen pack 104).
class WellbeingCheckInScreen extends ConsumerStatefulWidget {
  const WellbeingCheckInScreen({super.key});

  @override
  ConsumerState<WellbeingCheckInScreen> createState() =>
      _WellbeingCheckInScreenState();
}

class _WellbeingCheckInScreenState
    extends ConsumerState<WellbeingCheckInScreen> {
  late int _score = ref.read(wellbeingProvider).latestCheckIn?.score ?? 3;
  final _reflection = TextEditingController();

  @override
  void dispose() {
    _reflection.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return WellbeingPage(
      backFallback: RoutePaths.wellbeingPlan,
      children: [
        const ScreenTitle(
          title: 'How is your week going?',
          subtitle: 'Reflect on your personal goal. There is no right answer.',
        ),
        const SizedBox(height: 16),
        const FieldLabel('How manageable has your routine felt?'),
        Row(
          children: [
            for (var n = 1; n <= 5; n++) ...[
              if (n > 1) const SizedBox(width: 7),
              Expanded(
                child: Semantics(
                  selected: n == _score,
                  button: true,
                  child: Material(
                    color: n == _score
                        ? palette.tintGreenStrong
                        : palette.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: n == _score ? palette.positive : palette.line,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => setState(() => _score = n),
                      child: SizedBox(
                        height: 52,
                        child: Center(
                          child: Text(
                            '$n',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: n == _score
                                  ? palette.positive
                                  : palette.ink,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              'More difficult',
              style: TextStyle(fontSize: 12, color: palette.inkMuted),
            ),
            const Spacer(),
            Text(
              'Very manageable',
              style: TextStyle(fontSize: 12, color: palette.inkMuted),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextAreaField(
          label: 'Your reflection',
          controller: _reflection,
          optional: true,
          hintText: 'For example, I am taking one small step at a time',
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'Save check-in',
          onPressed: () {
            final text = _reflection.text.trim();
            ref
                .read(wellbeingProvider.notifier)
                .checkIn(
                  WellbeingCheckIn(
                    score: _score,
                    at: DateTime.now(),
                    reflection: text.isEmpty ? null : text,
                  ),
                );
            context.goBack(fallback: RoutePaths.wellbeingPlan);
          },
        ),
      ],
    );
  }
}
