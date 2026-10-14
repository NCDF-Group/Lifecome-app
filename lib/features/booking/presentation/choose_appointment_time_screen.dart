import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/feedback/empty_state.dart';
import '../../../core/widgets/feedback/error_state.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/feedback/loading_indicator.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/media/avatar.dart';
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
                  const AppHeaderBar(showBack: true),
                  const SizedBox(height: 20),
                  const ScreenTitle(
                    title: 'Choose a time',
                    subtitle: 'Select a date, time and how you would like to be seen.',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Material(
                    color: context.palette.tintGreen,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      onTap: () => context.push(
                        RoutePaths.doctorsProfile,
                        extra: widget.selection,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Row(
                          children: [
                            UserAvatar(name: doctor.name, radius: 22),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doctor.name,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: context.palette.ink,
                                    ),
                                  ),
                                  Text(
                                    doctor.specialty,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.palette.inkMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: context.palette.accent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
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
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: context.palette.ink,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < allowed.length; i++) ...[
                            Expanded(
                              child: _ModeCard(
                                icon: allowed[i] == ConsultationMode.video
                                    ? Icons.videocam_outlined
                                    : Icons.call_outlined,
                                title: allowed[i].label,
                                subtitle: allowed[i] == ConsultationMode.video
                                    ? 'See the GP online'
                                    : 'Speak by phone',
                                selected: _mode == allowed[i],
                                onTap: () => setState(() => _mode = allowed[i]),
                              ),
                            ),
                            if (i != allowed.length - 1)
                              const SizedBox(width: AppSpacing.sm),
                          ],
                        ],
                      ),
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
                icon: Icons.arrow_forward,
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
          'Select a date',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: context.palette.ink,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
            itemBuilder: (context, index) => SizedBox(
              width: 82,
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
                fontSize: 16,
                fontWeight: FontWeight.w600,
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
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.xs,
          crossAxisSpacing: AppSpacing.xs,
          childAspectRatio: 2.1,
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

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? context.palette.tintBlue : context.palette.elevated,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: selected ? context.palette.accent : context.palette.line,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: context.palette.ink, size: 20),
                  const Spacer(),
                  _RadioCircle(selected: selected),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: context.palette.ink,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: context.palette.inkMuted),
              ),
            ],
          ),
        ),
      ),
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
    return Material(
      color: selected ? context.palette.tintBlue : context.palette.elevated,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: selected ? context.palette.accent : context.palette.line,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Text(
                weekday,
                style: TextStyle(fontSize: 12, color: context.palette.inkMuted),
              ),
              Text(
                '${day.day} ${Formatters.shortDate(day).split(' ').last}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: context.palette.ink,
                ),
              ),
              const SizedBox(height: 4),
              _RadioCircle(selected: selected),
            ],
          ),
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
    return Material(
      color: selected ? AppColors.blue : context.palette.surface,
      borderRadius: BorderRadius.circular(AppRadius.control),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.control),
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          child: Text(
            time,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: selected ? AppColors.white : context.palette.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class _RadioCircle extends StatelessWidget {
  const _RadioCircle({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? context.palette.accent : context.palette.line,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.blue,
                ),
              ),
            )
          : null,
    );
  }
}
