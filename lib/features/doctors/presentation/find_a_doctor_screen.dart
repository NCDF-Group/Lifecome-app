import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../booking/domain/models/appointment.dart';
import '../domain/models/doctor.dart';

enum _ConsultationMode { video, telephone }

const _sampleSlots = {
  'dr-adaeze-okafor': [
    ('Today', '10:00'),
    ('Today', '11:30'),
    ('Today', '14:00'),
    ('Tomorrow', '09:00'),
  ],
  'dr-musa-bello': [
    ('Today', '09:30'),
    ('Today', '13:00'),
    ('Tomorrow', '10:00'),
    ('Tomorrow', '15:30'),
  ],
  'dr-ngozi-eze': [
    ('Today', '09:00'),
    ('Tomorrow', '11:00'),
    ('Tomorrow', '14:30'),
    ('Tomorrow', '16:00'),
  ],
};

/// Blueprint view 11 — Find a Doctor ("Find an appointment"). No
/// provider-directory backend exists yet, so the doctor list and their
/// time slots are static sample data.
class FindADoctorScreen extends StatefulWidget {
  const FindADoctorScreen({super.key, required this.selection});

  final BookingSelection selection;

  @override
  State<FindADoctorScreen> createState() => _FindADoctorScreenState();
}

class _FindADoctorScreenState extends State<FindADoctorScreen> {
  _ConsultationMode _mode = _ConsultationMode.video;

  void _pickSlot(Doctor doctor, String day, String time) {
    final now = DateTime.now();
    final date = day == 'Today' ? now : now.add(const Duration(days: 1));
    context.push(
      RoutePaths.bookingBeforeYourVisit,
      extra: widget.selection.copyWith(
        doctor: doctor,
        date: DateTime(date.year, date.month, date.day),
        time: time,
        consultationType: _mode == _ConsultationMode.video
            ? 'Video consultation'
            : 'Telephone consultation',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            AppHeaderBar(showBack: true, onBack: () => context.pop()),
            const SizedBox(height: 20),
            const Text(
              'Find an appointment',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Choose how you'd like to see a GP and find a time that "
              'works for you.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.inkMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _ModeButton(
                    icon: Icons.desktop_windows_outlined,
                    label: 'Video',
                    selected: _mode == _ConsultationMode.video,
                    onTap: () =>
                        setState(() => _mode = _ConsultationMode.video),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _ModeButton(
                    icon: Icons.call_outlined,
                    label: 'Telephone',
                    selected: _mode == _ConsultationMode.telephone,
                    onTap: () =>
                        setState(() => _mode = _ConsultationMode.telephone),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                _FilterChip(
                  icon: Icons.calendar_today_outlined,
                  label: 'Date',
                  onTap: () =>
                      showComingSoonPopup(context, feature: 'Date filter'),
                ),
                const SizedBox(width: AppSpacing.xs),
                _FilterChip(
                  icon: Icons.language,
                  label: 'Language',
                  onTap: () =>
                      showComingSoonPopup(context, feature: 'Language filter'),
                ),
                const SizedBox(width: AppSpacing.xs),
                _FilterChip(
                  icon: Icons.schedule_outlined,
                  label: 'Availability',
                  onTap: () => showComingSoonPopup(
                    context,
                    feature: 'Availability filter',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            for (var i = 0; i < sampleDoctors.length; i++) ...[
              _DoctorCard(
                doctor: sampleDoctors[i],
                green: i.isEven,
                slots: _sampleSlots[sampleDoctors[i].id] ?? const [],
                selectedSlot: i == 0 ? 0 : null,
                onViewProfile: () => context.push(
                  RoutePaths.doctorsProfile,
                  extra: widget.selection.copyWith(doctor: sampleDoctors[i]),
                ),
                onPickSlot: (day, time) =>
                    _pickSlot(sampleDoctors[i], day, time),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
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
    return Material(
      color: selected ? AppColors.blue : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.control),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.control),
        onTap: onTap,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? AppColors.white : AppColors.ink,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.white : AppColors.ink,
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
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
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
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppColors.ink),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: AppColors.inkMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({
    required this.doctor,
    required this.green,
    required this.slots,
    required this.onViewProfile,
    required this.onPickSlot,
    this.selectedSlot,
  });

  final Doctor doctor;
  final bool green;
  final List<(String, String)> slots;
  final int? selectedSlot;
  final VoidCallback onViewProfile;
  final void Function(String day, String time) onPickSlot;

  @override
  Widget build(BuildContext context) {
    final background = green
        ? const Color(0xFFEAF7E8)
        : const Color(0xFFE3EEFB);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundColor: Color(0xFFD9E3EC),
                child: Icon(Icons.person, color: Color(0xFF8AA0B4), size: 30),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const Text(
                      'GP',
                      style: TextStyle(fontSize: 13, color: AppColors.inkMuted),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline,
                          size: 13,
                          color: AppColors.inkMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          doctor.languages.first,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onViewProfile,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View profile',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.blue,
                      ),
                    ),
                    Icon(Icons.chevron_right, size: 16, color: AppColors.blue),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Text(
                'Available times',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const Spacer(),
              Text(
                'Sample availability',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.inkMuted.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              for (var i = 0; i < slots.length; i++) ...[
                Expanded(
                  child: _SlotPill(
                    day: slots[i].$1,
                    time: slots[i].$2,
                    selected: i == selectedSlot,
                    onTap: () => onPickSlot(slots[i].$1, slots[i].$2),
                  ),
                ),
                if (i != slots.length - 1) const SizedBox(width: 6),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _SlotPill extends StatelessWidget {
  const _SlotPill({
    required this.day,
    required this.time,
    required this.selected,
    required this.onTap,
  });

  final String day;
  final String time;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.blue : AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.control),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.control),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          alignment: Alignment.center,
          child: Column(
            children: [
              Text(
                day,
                style: TextStyle(
                  fontSize: 11,
                  color: selected
                      ? AppColors.white.withValues(alpha: 0.85)
                      : AppColors.inkMuted,
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: selected ? AppColors.white : AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
