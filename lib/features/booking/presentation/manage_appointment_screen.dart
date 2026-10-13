import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../domain/models/appointment.dart';

/// "Manage appointment" — change, cancel or get help with a just-booked
/// appointment. No cancellation/reschedule backend exists yet, so every
/// row below the summary opens a coming-soon popup.
class ManageAppointmentScreen extends StatelessWidget {
  const ManageAppointmentScreen({super.key, required this.selection});

  final BookingSelection selection;

  @override
  Widget build(BuildContext context) {
    final date = selection.date;
    final when = date == null
        ? ''
        : '${_weekday(date)} ${date.day} ${_month(date)}, ${selection.time ?? ''}';

    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            AppHeaderBar(showBack: true, onBack: () => context.pop()),
            const SizedBox(height: 20),
            Text(
              'Manage appointment',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: context.palette.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Change or cancel your appointment, or view more details.',
              style: TextStyle(
                fontSize: 14,
                color: context.palette.inkMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.palette.tintBlue,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: context.palette.elevated,
                    child: Icon(
                      Icons.videocam_outlined,
                      color: context.palette.accent,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Video GP',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: context.palette.ink,
                          ),
                        ),
                        Text(
                          when,
                          style: TextStyle(
                            fontSize: 13,
                            color: context.palette.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ActionRow(
              icon: Icons.calendar_month_outlined,
              background: context.palette.tintGreen,
              iconColor: context.palette.positive,
              title: 'Reschedule appointment',
              subtitle: 'Choose a new date or time.',
              onTap: () => showComingSoonPopup(
                context,
                feature: 'Rescheduling an appointment',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ActionRow(
              icon: Icons.delete_outline,
              background: context.palette.tintRed,
              iconColor: context.palette.danger,
              title: 'Cancel appointment',
              subtitle: 'View any refund or fee before confirming.',
              onTap: () => showComingSoonPopup(
                context,
                feature: 'Cancelling an appointment',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ActionRow(
              icon: Icons.description_outlined,
              background: context.palette.tintBlue,
              iconColor: context.palette.accent,
              title: 'View receipt',
              subtitle: 'See your payment details.',
              onTap: () =>
                  showComingSoonPopup(context, feature: 'View receipt'),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ActionRow(
              icon: Icons.support_agent_outlined,
              background: context.palette.tintBlue,
              iconColor: context.palette.accent,
              title: 'Contact support',
              subtitle: 'Get help with your appointment.',
              onTap: () =>
                  showComingSoonPopup(context, feature: 'Contact support'),
            ),
            const SizedBox(height: AppSpacing.md),
            Material(
              color: AppColors.blue,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                onTap: () => context.pop(),
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back, color: AppColors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Back to appointment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _weekday(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return weekdays[date.weekday - 1];
  }

  static String _month(DateTime date) {
    const months = [
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
    return months[date.month - 1];
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.background,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.palette.elevated,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      style: TextStyle(
                        fontSize: 12.5,
                        color: context.palette.inkMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: iconColor),
            ],
          ),
        ),
      ),
    );
  }
}
