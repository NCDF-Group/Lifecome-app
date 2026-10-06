import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../domain/models/appointment.dart';

const _times = [
  '9:00 AM',
  '9:30 AM',
  '10:00 AM',
  '10:30 AM',
  '11:00 AM',
  '2:00 PM',
  '2:30 PM',
  '3:00 PM',
];

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
    7,
    (i) => DateTime.now().add(Duration(days: i)),
  );
  late DateTime _selectedDay = _days.first;
  String _selectedTime = _times.first;

  @override
  Widget build(BuildContext context) {
    final doctor = widget.selection.doctor!;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'Choose your appointment',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.control),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.blue.withValues(
                            alpha: 0.1,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: AppColors.blue,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctor.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                            Text(
                              widget.selection.consultationType,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Select a date',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    height: 72,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _days.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(width: AppSpacing.xs),
                      itemBuilder: (context, index) {
                        final day = _days[index];
                        final selected =
                            day.day == _selectedDay.day &&
                            day.month == _selectedDay.month;
                        return _DayChip(
                          day: day,
                          isToday: index == 0,
                          selected: selected,
                          onTap: () => setState(() => _selectedDay = day),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Available time slots',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      for (final time in _times)
                        _TimeChip(
                          time: time,
                          selected: time == _selectedTime,
                          onTap: () => setState(() => _selectedTime = time),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'All times are West Africa Time (WAT).',
                    style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: PrimaryButton(
                label: 'Continue with $_selectedTime',
                icon: Icons.arrow_forward,
                onPressed: () => context.push(
                  RoutePaths.bookingBeforeYourVisit,
                  extra: widget.selection.copyWith(
                    date: _selectedDay,
                    time: _selectedTime,
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

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.day,
    required this.isToday,
    required this.selected,
    required this.onTap,
  });

  final DateTime day;
  final bool isToday;
  final bool selected;
  final VoidCallback onTap;

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.blue : AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.control),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.control),
        onTap: onTap,
        child: Container(
          width: 64,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.control),
            border: Border.all(
              color: selected ? AppColors.blue : AppColors.line,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isToday ? 'Today' : _weekdays[day.weekday - 1],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.white : AppColors.inkMuted,
                ),
              ),
              Text(
                '${day.day}',
                style: TextStyle(
                  fontSize: 16,
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
      color: selected ? AppColors.blue : AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.control),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.control),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.control),
            border: Border.all(
              color: selected ? AppColors.blue : AppColors.line,
            ),
          ),
          child: Text(
            time,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.white : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
