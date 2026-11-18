import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/router/safe_back.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/buttons/secondary_button.dart';
import '../../../core/widgets/feedback/error_state.dart';
import '../../../core/widgets/feedback/skeleton_loader.dart';
import '../../../core/widgets/feedback/status_chip.dart';
import '../../../core/widgets/inputs/choice_card.dart';
import '../../../core/widgets/inputs/form_fields.dart';
import '../../../core/widgets/inputs/slot_picker.dart';
import '../../../core/widgets/layout/detail_list.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../booking/application/booking_controller.dart';
import '../../booking/domain/models/availability_slot.dart';
import '../../doctors/domain/models/doctor.dart';
import '../application/wellbeing_controller.dart';
import '../domain/wellbeing_models.dart';
import 'wellbeing_widgets.dart';

class WellbeingPractitionerSelection {
  const WellbeingPractitionerSelection({
    required this.offer,
    required this.practitioner,
  });

  final WellbeingOffer offer;
  final Doctor practitioner;
}

class WellbeingBookingDraft {
  const WellbeingBookingDraft({
    required this.offer,
    required this.practitioner,
    required this.slot,
  });

  final WellbeingOffer offer;
  final Doctor practitioner;
  final AvailabilitySlot slot;
}

List<(String, String)> wellbeingDetails(WellbeingBookingDraft draft) => [
  ('Session', draft.offer.title),
  ('Practitioner', draft.practitioner.name),
  ('Date', Formatters.longDate(draft.slot.startsAt.toLocal())),
  ('Time', '${Formatters.time(draft.slot.startsAt.toLocal())} · local time'),
  ('Format', 'Online · ${draft.offer.durationMinutes} minutes'),
  ('Fee', Formatters.money(draft.offer.pricePence)),
];

/// Choose an actual open slot returned by the scheduling API.
class WellbeingSlotsScreen extends ConsumerStatefulWidget {
  const WellbeingSlotsScreen({super.key, required this.selection});

  final WellbeingPractitionerSelection selection;

  @override
  ConsumerState<WellbeingSlotsScreen> createState() =>
      _WellbeingSlotsScreenState();
}

class _WellbeingSlotsScreenState extends ConsumerState<WellbeingSlotsScreen> {
  AvailabilitySlot? _chosen;

  @override
  Widget build(BuildContext context) {
    final selection = widget.selection;
    final availability = ref.watch(
      availabilityProvider(selection.practitioner.id),
    );
    return WellbeingPage(
      children: [
        ScreenTitle(
          title: 'Choose a time',
          subtitle: '${selection.offer.title} · ${selection.practitioner.name}',
        ),
        const SizedBox(height: 10),
        availability.when(
          loading: () => const SkeletonLoader(),
          error: (error, _) => ErrorState(
            error: error,
            onRetry: () =>
                ref.invalidate(availabilityProvider(selection.practitioner.id)),
          ),
          data: (slots) {
            if (slots.isEmpty) {
              return const Text(
                'No available times right now. Please check again later.',
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SlotPicker(
                  slots: [for (final slot in slots) slot.startsAt.toLocal()],
                  selected: _chosen?.startsAt.toLocal(),
                  onSelected: (picked) {
                    final match = slots.where(
                      (slot) =>
                          slot.startsAt.toLocal().isAtSameMomentAs(picked),
                    );
                    if (match.isNotEmpty) setState(() => _chosen = match.first);
                  },
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                  label: 'Continue',
                  onPressed: _chosen == null
                      ? null
                      : () => context.push(
                          RoutePaths.wellbeingReview,
                          extra: WellbeingBookingDraft(
                            offer: selection.offer,
                            practitioner: selection.practitioner,
                            slot: _chosen!,
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class WellbeingReviewScreen extends ConsumerStatefulWidget {
  const WellbeingReviewScreen({super.key, required this.draft});

  final WellbeingBookingDraft draft;

  @override
  ConsumerState<WellbeingReviewScreen> createState() =>
      _WellbeingReviewScreenState();
}

class _WellbeingReviewScreenState extends ConsumerState<WellbeingReviewScreen> {
  final _notes = TextEditingController();
  String? _notesError;
  bool _agreed = false;
  bool _showAgreeError = false;
  bool _submitting = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    setState(
      () => _notesError = Validators.text(
        _notes.text,
        label: 'what you would like to focus on',
        required: true,
        minLength: 5,
      ),
    );
    if (_notesError != null || !_agreed) {
      setState(() => _showAgreeError = !_agreed);
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref
          .read(wellbeingProvider.notifier)
          .book(
            offer: widget.draft.offer,
            practitionerName: widget.draft.practitioner.name,
            startsAt: widget.draft.slot.startsAt,
            notes: _notes.text.trim(),
          );
      if (!mounted) return;
      context.go(RoutePaths.home);
      context.push(RoutePaths.wellbeing);
      context.push(RoutePaths.wellbeingConfirmed);
    } catch (error) {
      if (!mounted) return;
      final message = error is ApiException
          ? error.message
          : 'We could not book this session. Please try again.';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    return WellbeingPage(
      children: [
        const ScreenTitle(
          title: 'Review your session',
          subtitle:
              'Check your details and tell us what you would like to focus on.',
        ),
        const SizedBox(height: 10),
        DetailList(rows: wellbeingDetails(draft)),
        TextAreaField(
          label: 'What would you like to focus on?',
          controller: _notes,
          hintText: 'Add a note for your practitioner',
          errorText: _notesError,
        ),
        CheckRow(
          value: _agreed,
          onChanged: (value) => setState(() {
            _agreed = value;
            if (value) _showAgreeError = false;
          }),
          label: 'I have reviewed and agree to these session details.',
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
        PrimaryButton(
          label: _submitting ? 'Booking…' : 'Confirm session',
          onPressed: _submitting ? null : _confirm,
        ),
      ],
    );
  }
}

class WellbeingConfirmedScreen extends ConsumerWidget {
  const WellbeingConfirmedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wellbeingProvider);
    final current = state.asData?.value;
    final session = current != null && current.sessions.isNotEmpty
        ? current.sessions.first
        : null;
    return WellbeingPage(
      children: [
        const SuccessIcon(),
        const ScreenTitle(
          title: 'Session booked',
          subtitle: 'Your wellbeing session has been saved.',
        ),
        const SizedBox(height: 12),
        const StatusBadge('Confirmed'),
        if (session != null)
          DetailList(
            rows: [
              ('Session', session.offer.title),
              ('Practitioner', session.practitionerName),
              ('Date', Formatters.longDate(session.startsAt.toLocal())),
              ('Time', Formatters.time(session.startsAt.toLocal())),
            ],
          ),
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
