import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/feedback/empty_state.dart';
import '../../../core/widgets/feedback/error_state.dart';
import '../../../core/widgets/feedback/loading_indicator.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/layout/step_progress.dart';
import '../../../core/widgets/media/lc_icons.dart';
import '../../../core/widgets/media/avatar.dart';
import '../../booking/application/booking_controller.dart';
import '../../booking/domain/models/availability_slot.dart';
import '../../booking/domain/models/booking_selection.dart';
import '../../booking/domain/models/consultation_mode.dart';
import '../application/doctor_search_controller.dart';
import '../domain/models/doctor.dart';

/// How many times each clinician's card previews.
const _previewSlots = 4;

/// Blueprint view 11 — Find a Doctor ("Find an appointment"). The clinicians
/// come from the backend's directory and each card previews their next free
/// times; nothing here is sample data.
class FindADoctorScreen extends ConsumerStatefulWidget {
  const FindADoctorScreen({super.key, required this.selection});

  final BookingSelection selection;

  @override
  ConsumerState<FindADoctorScreen> createState() => _FindADoctorScreenState();
}

class _FindADoctorScreenState extends ConsumerState<FindADoctorScreen> {
  late ConsultationMode _mode = widget.selection.mode;
  String? _language;
  DateTime? _day;

  bool get _inPerson => _mode == ConsultationMode.inPerson;

  void _pickSlot(Doctor doctor, AvailabilitySlot slot) {
    context.push(
      RoutePaths.bookingBeforeYourVisit,
      extra: widget.selection.copyWith(doctor: doctor, slot: slot, mode: _mode),
    );
  }

  Future<void> _chooseLanguage(List<String> languages) async {
    final chosen = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: const Text('Any language'),
              trailing: _language == null
                  ? Icon(Icons.check, color: context.palette.accent)
                  : null,
              onTap: () => Navigator.of(context).pop(''),
            ),
            for (final language in languages)
              ListTile(
                title: Text(language),
                trailing: language == _language
                    ? Icon(Icons.check, color: context.palette.accent)
                    : null,
                onTap: () => Navigator.of(context).pop(language),
              ),
          ],
        ),
      ),
    );
    if (chosen == null) return;
    setState(() => _language = chosen.isEmpty ? null : chosen);
  }

  Future<void> _chooseDay() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _day ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 90)),
      helpText: 'Show times on',
    );
    if (picked == null) return;
    setState(() => _day = DateTime(picked.year, picked.month, picked.day));
  }

  List<Doctor> _visible(List<Doctor> all) {
    final matches = [
      for (final doctor in all)
        if (doctor.offers(_mode) &&
            (_language == null || doctor.languages.contains(_language)))
          doctor,
    ];
    final city = widget.selection.city?.toLowerCase();
    if (_inPerson && city != null && city.isNotEmpty) {
      // Clinics in the person's own town first.
      matches.sort((a, b) {
        final aNear = (a.city ?? '').toLowerCase() == city ? 0 : 1;
        final bNear = (b.city ?? '').toLowerCase() == city ? 0 : 1;
        return aNear.compareTo(bNear);
      });
    }
    return matches;
  }

  @override
  Widget build(BuildContext context) {
    final doctors = ref.watch(doctorsProvider);
    final languages = doctors.hasValue
        ? ({for (final doctor in doctors.requireValue) ...doctor.languages}
              .toList()
            ..sort())
        : <String>[];

    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const AppHeaderBar(showBack: true, backFallback: RoutePaths.gp),
            const StepProgress(step: 3, total: 6),
            ScreenTitle(
              title: _inPerson ? 'Choose your clinic' : 'Choose your GP',
              subtitle:
                  'Find the right person for your appointment, then '
                  'pick a time or view their profile.',
            ),
            const SizedBox(height: AppSpacing.md),
            if (!_inPerson) ...[
              Row(
                children: [
                  Expanded(
                    child: _ModeButton(
                      icon: Icons.desktop_windows_outlined,
                      label: 'Video',
                      selected: _mode == ConsultationMode.video,
                      onTap: () =>
                          setState(() => _mode = ConsultationMode.video),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _ModeButton(
                      icon: Icons.call_outlined,
                      label: 'Telephone',
                      selected: _mode == ConsultationMode.audio,
                      onTap: () =>
                          setState(() => _mode = ConsultationMode.audio),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            Row(
              children: [
                _FilterChip(
                  icon: Icons.calendar_today_outlined,
                  label: _day == null ? 'Date' : Formatters.shortDate(_day!),
                  active: _day != null,
                  onTap: _chooseDay,
                ),
                const SizedBox(width: AppSpacing.xs),
                _FilterChip(
                  icon: Icons.language,
                  label: _language ?? 'Language',
                  active: _language != null,
                  onTap: languages.isEmpty
                      ? null
                      : () => _chooseLanguage(languages),
                ),
                if (_day != null || _language != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  TextButton(
                    onPressed: () => setState(() {
                      _day = null;
                      _language = null;
                    }),
                    child: const Text('Clear'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            doctors.when(
              loading: () => const LoadingIndicator(),
              error: (error, _) => ErrorState(
                error: error,
                onRetry: () => ref.invalidate(doctorsProvider),
              ),
              data: (all) {
                final visible = _visible(all);
                if (visible.isEmpty) {
                  return EmptyState(
                    icon: Icons.person_search_outlined,
                    title: all.isEmpty
                        ? 'No clinicians are available yet'
                        : 'No clinicians match',
                    message: all.isEmpty
                        ? 'Please check back soon.'
                        : (_inPerson
                              ? 'No clinic offers in-person appointments '
                                    'with these filters.'
                              : 'Try a different appointment type or '
                                    'language.'),
                    actionLabel: _language != null || _day != null
                        ? 'Clear filters'
                        : null,
                    onAction: () => setState(() {
                      _day = null;
                      _language = null;
                    }),
                  );
                }
                return Column(
                  children: [
                    for (var i = 0; i < visible.length; i++) ...[
                      _DoctorCard(
                        doctor: visible[i],
                        green: i.isEven,
                        day: _day,
                        onViewProfile: () => context.push(
                          RoutePaths.doctorsProfile,
                          extra: widget.selection.copyWith(
                            doctor: visible[i],
                            mode: _mode,
                          ),
                        ),
                        onPickSlot: (slot) => _pickSlot(visible[i], slot),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: selected ? palette.tintBlueFaint : palette.elevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        side: BorderSide(color: selected ? palette.accent : palette.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.control),
        onTap: onTap,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? palette.accent : palette.ink,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: selected ? palette.accent : palette.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? context.palette.tintBlue : context.palette.elevated,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: active ? context.palette.accent : context.palette.line,
            ),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: context.palette.ink),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.palette.ink,
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: context.palette.inkMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoctorCard extends ConsumerWidget {
  const _DoctorCard({
    required this.doctor,
    required this.green,
    required this.day,
    required this.onViewProfile,
    required this.onPickSlot,
  });

  final Doctor doctor;
  final bool green;
  final DateTime? day;
  final VoidCallback onViewProfile;
  final void Function(AvailabilitySlot slot) onPickSlot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final slots = ref.watch(availabilityProvider(doctor.id));

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.elevated,
        border: Border.all(color: palette.line),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onViewProfile,
            borderRadius: BorderRadius.circular(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserAvatar(name: doctor.name, radius: 24),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: palette.ink,
                        ),
                      ),
                      Text(
                        doctor.specialty,
                        style: TextStyle(fontSize: 13, color: palette.inkMuted),
                      ),
                      if (doctor.languages.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 13,
                              color: palette.inkMuted,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                doctor.languages.join(', '),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: palette.inkMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (doctor.locationLabel != null)
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 13,
                              color: palette.inkMuted,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                doctor.locationLabel!,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: palette.inkMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'View profile',
                  child: Padding(
                    padding: const EdgeInsets.only(top: 14, left: 8),
                    child: LcIcon(
                      LcIcons.chevron,
                      size: 16,
                      color: palette.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Available times',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: palette.ink,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          slots.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (error, _) => Row(
              children: [
                Expanded(
                  child: Text(
                    "Couldn't load times.",
                    style: TextStyle(fontSize: 13, color: palette.danger),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      ref.invalidate(availabilityProvider(doctor.id)),
                  child: const Text('Retry'),
                ),
              ],
            ),
            data: (all) {
              final shown = [
                for (final slot in all)
                  if (day == null ||
                      (slot.ukDay.year == day!.year &&
                          slot.ukDay.month == day!.month &&
                          slot.ukDay.day == day!.day))
                    slot,
              ].take(_previewSlots).toList();
              if (shown.isEmpty) {
                return Text(
                  day == null
                      ? 'No times available right now.'
                      : 'No times on ${Formatters.shortDate(day!)}.',
                  style: TextStyle(fontSize: 13, color: palette.inkMuted),
                );
              }
              // Always four columns, so one free time is one pill wide, not
              // a bar across the card.
              return Row(
                children: [
                  for (var i = 0; i < _previewSlots; i++) ...[
                    Expanded(
                      child: i < shown.length
                          ? _SlotPill(
                              day: Formatters.dayLabel(shown[i].ukDay),
                              time: shown[i].ukClock,
                              onTap: () => onPickSlot(shown[i]),
                            )
                          : const SizedBox.shrink(),
                    ),
                    if (i != _previewSlots - 1) const SizedBox(width: 6),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SlotPill extends StatelessWidget {
  const _SlotPill({required this.day, required this.time, required this.onTap});

  final String day;
  final String time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.palette.elevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: context.palette.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          alignment: Alignment.center,
          child: Column(
            children: [
              Text(
                day,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: context.palette.inkMuted),
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.palette.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
