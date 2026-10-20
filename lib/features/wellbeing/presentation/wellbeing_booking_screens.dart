import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/router/safe_back.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/buttons/secondary_button.dart';
import '../../../core/widgets/feedback/status_chip.dart';
import '../../../core/widgets/inputs/choice_card.dart';
import '../../../core/widgets/inputs/form_fields.dart';
import '../../../core/widgets/inputs/slot_picker.dart';
import '../../../core/widgets/layout/detail_list.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../application/wellbeing_controller.dart';
import '../domain/wellbeing_models.dart';
import 'wellbeing_widgets.dart';

/// An offer and a chosen time, on their way to the review screen.
class WellbeingBookingDraft {
  const WellbeingBookingDraft({required this.offer, required this.startsAt});

  final WellbeingOffer offer;
  final DateTime startsAt;
}

/// The session's offer, practitioner and time, as detail rows.
List<(String, String)> wellbeingDetails(
  WellbeingOffer offer,
  DateTime startsAt,
) => [
  ('Session', offer.title),
  ('Practitioner', WellbeingPractitioner.name),
  ('Date', Formatters.longDate(startsAt)),
  ('Time', '${Formatters.time(startsAt)} · UK time'),
  ('Format', 'Online · ${WellbeingOffer.durationMinutes} minutes'),
];

/// "Find time for yourself" (screen pack 096), or "Choose another time"
/// for the booked session (100) when [offer] is null.
class WellbeingSlotsScreen extends ConsumerStatefulWidget {
  const WellbeingSlotsScreen({super.key, this.offer});

  final WellbeingOffer? offer;

  @override
  ConsumerState<WellbeingSlotsScreen> createState() =>
      _WellbeingSlotsScreenState();
}

class _WellbeingSlotsScreenState extends ConsumerState<WellbeingSlotsScreen> {
  final _slots = wellbeingSlots();
  DateTime? _chosen;

  bool get _rescheduling => widget.offer == null;

  void _continue() {
    final chosen = _chosen;
    if (chosen == null) return;
    if (_rescheduling) {
      ref.read(wellbeingProvider.notifier).reschedule(chosen);
      context.goBack(fallback: RoutePaths.wellbeingSession);
    } else {
      context.push(
        RoutePaths.wellbeingReview,
        extra: WellbeingBookingDraft(offer: widget.offer!, startsAt: chosen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer ?? ref.watch(wellbeingProvider).session?.offer;
    return WellbeingPage(
      children: [
        ScreenTitle(
          title: _rescheduling
              ? 'Choose another time'
              : 'Find time for yourself',
          subtitle: _rescheduling
              ? 'Your session moves when you confirm the new time.'
              : '${offer?.title ?? 'Wellbeing session'} · '
                    '${WellbeingPractitioner.name}',
        ),
        const SizedBox(height: 10),
        SlotPicker(
          slots: _slots,
          selected: _chosen,
          onSelected: (slot) => setState(() => _chosen = slot),
        ),
        const SizedBox(height: 18),
        PrimaryButton(
          label: _rescheduling ? 'Confirm new time' : 'Continue',
          onPressed: _chosen == null ? null : _continue,
        ),
      ],
    );
  }
}

/// "Review your session" (screen pack 097): goal, details and how it is
/// paid for, then confirmation.
class WellbeingReviewScreen extends ConsumerStatefulWidget {
  const WellbeingReviewScreen({super.key, required this.draft});

  final WellbeingBookingDraft draft;

  @override
  ConsumerState<WellbeingReviewScreen> createState() =>
      _WellbeingReviewScreenState();
}

class _WellbeingReviewScreenState extends ConsumerState<WellbeingReviewScreen> {
  final _goal = TextEditingController();
  String? _goalError;
  bool _agreed = false;
  bool _showAgreeError = false;

  @override
  void dispose() {
    _goal.dispose();
    super.dispose();
  }

  void _confirm() {
    final goalError = Validators.text(
      _goal.text,
      label: 'what you would like to focus on',
      required: true,
      minLength: 5,
    );
    setState(() {
      _goalError = goalError;
      _showAgreeError = !_agreed;
    });
    if (goalError != null || !_agreed) return;
    ref
        .read(wellbeingProvider.notifier)
        .book(
          offer: widget.draft.offer,
          startsAt: widget.draft.startsAt,
          goal: _goal.text.trim(),
        );
    context.go(RoutePaths.home);
    context.push(RoutePaths.wellbeing);
    context.push(RoutePaths.wellbeingConfirmed);
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    return WellbeingPage(
      children: [
        const ScreenTitle(
          title: 'Review your session',
          subtitle: 'Check your details and tell us your goal.',
        ),
        const SizedBox(height: 10),
        DetailList(rows: wellbeingDetails(draft.offer, draft.startsAt)),
        TextAreaField(
          label: 'What would you like to focus on?',
          controller: _goal,
          hintText: 'For example, build a realistic routine that fits my week',
          errorText: _goalError,
        ),
        PanelCard(
          title: 'Payment',
          child: DetailList(
            rows: [
              ('Example fee', Formatters.money(draft.offer.pricePence)),
              ('Charged today', 'Nothing · preview'),
            ],
          ),
        ),
        CheckRow(
          value: _agreed,
          onChanged: (v) => setState(() {
            _agreed = v;
            if (v) _showAgreeError = false;
          }),
          label:
              'I have reviewed the session details and understand this is a '
              'preview booking.',
        ),
        if (_showAgreeError)
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Text(
              'Please confirm to continue.',
              style: TextStyle(fontSize: 12.5, color: context.palette.danger),
            ),
          ),
        const SizedBox(height: 16),
        PrimaryButton(label: 'Confirm session', onPressed: _confirm),
        const SizedBox(height: 12),
        const WellbeingPreviewNotice(),
      ],
    );
  }
}

/// "A little time for you" (screen pack 098).
class WellbeingConfirmedScreen extends ConsumerWidget {
  const WellbeingConfirmedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(wellbeingProvider).session;
    return WellbeingPage(
      children: [
        const SuccessIcon(),
        const ScreenTitle(
          title: 'A little time for you',
          subtitle: 'Your wellbeing session is booked.',
        ),
        const SizedBox(height: 12),
        const StatusBadge('Confirmed'),
        if (session != null)
          DetailList(rows: wellbeingDetails(session.offer, session.startsAt)),
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'View your session',
          onPressed: () => context.pushReplacement(RoutePaths.wellbeingSession),
        ),
        const SizedBox(height: 10),
        SecondaryButton(
          label: 'Back to Wellbeing',
          onPressed: () => context.goBack(fallback: RoutePaths.wellbeing),
        ),
      ],
    );
  }
}
