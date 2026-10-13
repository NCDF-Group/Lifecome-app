import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../domain/models/appointment.dart';

const _times = ['10:00', '10:30', '11:00', '11:30'];
const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
const _fullMonths = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];
const _fullWeekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

enum _ConsultationMode { video, telephone }

/// Blueprint view 13 — Choose Appointment Time.
class ChooseAppointmentTimeScreen extends StatefulWidget {
  const ChooseAppointmentTimeScreen({super.key, required this.selection});

  final BookingSelection selection;

  @override
  State<ChooseAppointmentTimeScreen> createState() =>
      _ChooseAppointmentTimeScreenState();
}

class _ChooseAppointmentTimeScreenState
    extends State<ChooseAppointmentTimeScreen> {
  late final _days = List.generate(
    3,
    (i) => DateTime.now().add(Duration(days: i)),
  );
  late DateTime _selectedDay = _days.first;
  String _selectedTime = _times[1];
  _ConsultationMode _mode = _ConsultationMode.video;

  @override
  Widget build(BuildContext context) {
    final doctor = widget.selection.doctor!;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  AppHeaderBar(showBack: true, onBack: () => context.pop()),
                  const SizedBox(height: 20),
                  const Text(
                    'Choose a time',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Select a date, time and how you would like to be seen.',
                    style: TextStyle(fontSize: 14, color: AppColors.inkMuted),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Material(
                    color: const Color(0xFFEAF7E8),
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
                            const CircleAvatar(
                              radius: 22,
                              backgroundColor: AppColors.white,
                              child: Icon(
                                Icons.person,
                                color: AppColors.greenStrong,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doctor.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                  Text(
                                    _mode == _ConsultationMode.video
                                        ? 'Online GP'
                                        : 'Telephone GP',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.inkMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: AppColors.blue,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'How would you like to be seen?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _ModeCard(
                            icon: Icons.videocam_outlined,
                            title: 'Video',
                            subtitle: 'See the GP online',
                            selected: _mode == _ConsultationMode.video,
                            onTap: () =>
                                setState(() => _mode = _ConsultationMode.video),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _ModeCard(
                            icon: Icons.call_outlined,
                            title: 'Telephone',
                            subtitle: 'Speak by phone',
                            selected: _mode == _ConsultationMode.telephone,
                            onTap: () => setState(
                              () => _mode = _ConsultationMode.telephone,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Select a date',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      for (var i = 0; i < _days.length; i++) ...[
                        Expanded(
                          child: _DayCard(
                            day: _days[i],
                            selected:
                                _days[i].day == _selectedDay.day &&
                                _days[i].month == _selectedDay.month,
                            onTap: () =>
                                setState(() => _selectedDay = _days[i]),
                          ),
                        ),
                        if (i != _days.length - 1)
                          const SizedBox(width: AppSpacing.xs),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      const Text(
                        'Available times',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'UK time (BST)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      for (var i = 0; i < _times.length; i++) ...[
                        Expanded(
                          child: _TimeChip(
                            time: _times[i],
                            selected: _times[i] == _selectedTime,
                            onTap: () =>
                                setState(() => _selectedTime = _times[i]),
                          ),
                        ),
                        if (i != _times.length - 1)
                          const SizedBox(width: AppSpacing.xs),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Sample availability',
                    style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF7E8),
                      borderRadius: BorderRadius.circular(AppRadius.control),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.white,
                          child: Icon(
                            Icons.calendar_month_outlined,
                            size: 18,
                            color: AppColors.greenStrong,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Selected appointment',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.inkMuted,
                                ),
                              ),
                              Text(
                                '${_fullWeekdays[_selectedDay.weekday - 1]} '
                                '${_selectedDay.day} '
                                '${_fullMonths[_selectedDay.month - 1]} '
                                '${_selectedDay.year} at $_selectedTime',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.ink,
                                ),
                              ),
                              Text(
                                '${_mode == _ConsultationMode.video ? 'Video' : 'Telephone'} '
                                'consultation with ${doctor.name}',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.inkMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: PrimaryButton(
                label: 'Continue',
                icon: Icons.arrow_forward,
                onPressed: () => context.push(
                  RoutePaths.bookingBeforeYourVisit,
                  extra: widget.selection.copyWith(
                    date: _selectedDay,
                    time: _selectedTime,
                    consultationType: _mode == _ConsultationMode.video
                        ? 'Video consultation'
                        : 'Telephone consultation',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
      color: selected ? const Color(0xFFE3EEFB) : AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: selected ? AppColors.blue : AppColors.line,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppColors.ink, size: 20),
                  const Spacer(),
                  _RadioCircle(selected: selected),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: AppColors.inkMuted),
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
    return Material(
      color: selected ? const Color(0xFFE3EEFB) : AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: selected ? AppColors.blue : AppColors.line,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Text(
                _weekdays[day.weekday - 1],
                style: const TextStyle(fontSize: 12, color: AppColors.inkMuted),
              ),
              Text(
                '${day.day} ${_months[day.month - 1]}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
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
      color: selected ? AppColors.blue : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.control),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.control),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          alignment: Alignment.center,
          child: Text(
            time,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: selected ? AppColors.white : AppColors.ink,
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
          color: selected ? AppColors.blue : AppColors.line,
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
