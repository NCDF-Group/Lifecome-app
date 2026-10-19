import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/feedback/empty_state.dart';
import '../../../core/widgets/feedback/error_state.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/feedback/loading_indicator.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/inputs/choice_card.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/layout/step_progress.dart';
import '../application/booking_controller.dart';
import '../domain/models/availability_slot.dart';
import '../domain/models/booking_selection.dart';
import '../domain/models/consultation_mode.dart';

/// How many days with free times the date row offers.
const _maxDays = 14;

/// Blueprint view 13 — Choose Appointment Time. The days and times are the
/// clinician's real free slots, shown in UK time.
class ChooseAppointmentTimeScreen extends ConsumerStatefulWidget {
  const ChooseAppointmentTimeScreen({super.key, required this.selection});

  final BookingSelection selection;

  @override
  ConsumerState<ChooseAppointmentTimeScreen> createState() =>
      _ChooseAppointmentTimeScreenState();
}

class _ChooseAppointmentTimeScreenState
    extends ConsumerState<ChooseAppointmentTimeScreen> {
  DateTime? _day;
  AvailabilitySlot? _slot;
  late ConsultationMode _mode;

  /// The appointment types this clinician offers that match what the patient
  /// asked for (online, or in person).
  List<ConsultationMode> get _allowedModes {
    final doctor = widget.selection.doctor!;
    final wantsInPerson = widget.selection.mode == ConsultationMode.inPerson;
    return [
      for (final mode in ConsultationMode.values)
        if (doctor.offers(mode) && mode.isOnline != wantsInPerson) mode,
    ];
  }

  @override
  void initState() {
    super.initState();
    final allowed = _allowedModes;
    _mode = allowed.contains(widget.selection.mode)
        ? widget.selection.mode
        : (allowed.isEmpty ? widget.selection.mode : allowed.first);
    _slot = widget.selection.slot;
    _day = _slot?.ukDay;
  }

  void _continue() {
    final slot = _slot;
    if (slot == null) return;
    context.push(
      RoutePaths.bookingBeforeYourVisit,
      extra: widget.selection.copyWith(slot: slot, mode: _mode),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doctor = widget.selection.doctor!;
    final slots = ref.watch(availabilityProvider(doctor.id));
    final allowed = _allowedModes;

    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  const AppHeaderBar(
                    showBack: true,
                    backFallback: RoutePaths.gp,
                  ),
                  const StepProgress(step: 4, total: 6),
                  ScreenTitle(
                    title: 'Choose your time',
                    subtitle:
                        '${doctor.name} · ${widget.selection.mode.isOnline ? 'Online GP' : 'In-clinic GP'}',
                  ),
                  const SizedBox(height: 16),
                  if (allowed.isEmpty)
                    const InfoBanner(
                      tone: BannerTone.warning,
                      message:
                          "This clinician doesn't offer that type of "
                          'appointment. Go back and choose another.',
                    )
                  else if (allowed.length > 1) ...[
                    Text(
                      'How would you like to be seen?',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: context.palette.ink,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    for (final mode in allowed)
                      ChoiceCard(
                        title: mode.label,
                        subtitle: mode == ConsultationMode.video
                            ? 'See the GP online'
                            : 'Speak by phone',
                        selected: _mode == mode,
                        onTap: () => setState(() => _mode = mode),
                      ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  slots.when(
                    loading: () => const LoadingIndicator(),
                    error: (error, _) => ErrorState(
                      error: error,
                      onRetry: () =>
                          ref.invalidate(availabilityProvider(doctor.id)),
                    ),
                    data: (all) => _times(context, all),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: PrimaryButton(
                label: 'Continue',
                onPressed: _slot == null || allowed.isEmpty ? null : _continue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _times(BuildContext context, List<AvailabilitySlot> all) {
    if (all.isEmpty) {
      return const EmptyState(
        icon: Icons.event_busy_outlined,
        title: 'No times available',
        message:
            'This clinician has no free times right now. Try another '
            'clinician, or check back later.',
      );
    }

    final days = <DateTime>[];
    for (final slot in all) {
      if (!days.contains(slot.ukDay)) days.add(slot.ukDay);
      if (days.length == _maxDays) break;
    }
    final day = days.contains(_day) ? _day! : days.first;
    final onDay = [
      for (final slot in all)
        if (slot.ukDay == day) slot,
    ];
    final chosen = _slot;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose a date',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: context.palette.ink,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
            itemBuilder: (context, index) => SizedBox(
              width: 74,
              child: _DayCard(
                day: days[index],
                selected: days[index] == day,
                onTap: () => setState(() {
                  _day = days[index];
                  if (_slot != null && _slot!.ukDay != days[index]) {
                    _slot = null;
                  }
                }),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Text(
              'Available times',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: context.palette.ink,
              ),
            ),
            const Spacer(),
            Text(
              'UK time (${Formatters.ukZoneLabel(onDay.first.startsAt)})',
              style: TextStyle(fontSize: 12, color: context.palette.inkMuted),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.xs,
          crossAxisSpacing: AppSpacing.xs,
          childAspectRatio: 2.6,
          children: [
            for (final slot in onDay)
              _TimeChip(
                time: slot.ukClock,
                selected: chosen?.id == slot.id,
                onTap: () => setState(() {
                  _slot = slot;
                  _day = slot.ukDay;
                }),
              ),
          ],
        ),
        if (chosen != null) ...[
          const SizedBox(height: AppSpacing.md),
          InfoBanner(
            tone: BannerTone.success,
            icon: Icons.calendar_month_outlined,
            title: 'Selected appointment',
            message:
                '${Formatters.appointmentWhen(chosen.startsAt)}\n'
                '${_mode.consultationLabel} with '
                '${widget.selection.doctor!.name}',
          ),
        ],
      ],
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.day,
    required this.selected,
    required this.onTap,
  });

  final DateTime day;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = Formatters.dayLabel(day);
    final weekday = label == 'Today' || label == 'Tomorrow'
        ? label
        : label.split(' ').first;
    final palette = context.palette;
    final color = selected ? palette.accent : palette.ink;
    return Material(
      color: selected ? palette.tintBlueFaint : palette.elevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(11),
        side: BorderSide(color: selected ? palette.accent : palette.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(weekday, style: TextStyle(fontSize: 11, color: color)),
            Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              Formatters.shortDate(day).split(' ').last,
              style: TextStyle(fontSize: 11, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.time,
    required this.selected,
    required this.onTap,
  });

  final String time;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: selected ? palette.tintBlueFaint : palette.elevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: selected ? palette.accent : palette.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          child: Text(
            time,
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? palette.accent : palette.ink,
            ),
          ),
        ),
      ),
    );
  }
}
