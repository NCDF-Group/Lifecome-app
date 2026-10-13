import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../domain/models/appointment.dart';

/// "Check your appointment" — the checklist shown right after booking,
/// before the visit itself: confirm the clinical suitability questions
/// and the funding/cover check. Reached from Booking confirmation's
/// "Prepare for your visit" row.
class AppointmentCheckScreen extends StatelessWidget {
  const AppointmentCheckScreen({super.key, required this.selection});

  final BookingSelection selection;

  @override
  Widget build(BuildContext context) {
    final doctor = selection.doctor;
    final date = selection.date;
    const city = 'London';

    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            AppHeaderBar(showBack: true, onBack: () => context.pop()),
            const SizedBox(height: 20),
            Text(
              'Check your appointment',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: context.palette.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Complete the steps below before your visit.',
              style: TextStyle(fontSize: 14, color: context.palette.inkMuted),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.palette.tintBlue,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                              selection.service?.title ?? 'GP consultation',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: context.palette.ink,
                              ),
                            ),
                            Text(
                              'Online video',
                              style: TextStyle(
                                fontSize: 13,
                                color: context.palette.inkMuted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 15,
                                  color: context.palette.inkMuted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  city,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: context.palette.inkMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: context.palette.tintGreen,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: context.palette.positive,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Location confirmed',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: context.palette.positive,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Divider(
                      height: 1,
                      color: context.palette.tintBlueLine,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _SummaryField(
                          icon: Icons.calendar_today_outlined,
                          label: 'DATE',
                          value: date == null ? '' : _formatDate(date),
                          valueSecondLine: selection.time,
                        ),
                      ),
                      Expanded(
                        child: _SummaryField(
                          icon: Icons.person_outline,
                          label: 'WITH',
                          value: doctor?.name ?? 'Your GP',
                          valueSecondLine: 'GP',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _CheckCard(
              background: context.palette.tintGreen,
              icon: Icons.assignment_outlined,
              iconColor: context.palette.positive,
              title: 'Clinical suitability',
              status: 'Complete questions',
              body:
                  'Help us check the selected service is appropriate for '
                  'your needs.',
              buttonLabel: 'Start check',
              onPressed: () => context.push(
                RoutePaths.bookingBeforeYourVisit,
                extra: selection,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _CheckCard(
              background: context.palette.tintBlue,
              icon: Icons.credit_card_outlined,
              iconColor: context.palette.accent,
              title: 'Funding',
              status: 'Check selected service',
              body:
                  'Confirm your cover for this appointment. Funding '
                  'approval does not confirm clinical suitability.',
              buttonLabel: 'Check cover',
              onPressed: () => context.push(
                RoutePaths.linkHealthPlan,
                extra: selection.hmoName,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Material(
              color: context.palette.tintRed,
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.card),
                onTap: () =>
                    showComingSoonPopup(context, feature: 'Emergency guidance'),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: context.palette.danger,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Need urgent help?',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: context.palette.danger,
                              ),
                            ),
                            Text(
                              'View emergency guidance.',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: context.palette.ink.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: context.palette.danger),
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

  static String _formatDate(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
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
    return '${weekdays[date.weekday - 1]} ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _SummaryField extends StatelessWidget {
  const _SummaryField({
    required this.icon,
    required this.label,
    required this.value,
    this.valueSecondLine,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? valueSecondLine;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: context.palette.inkMuted),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: context.palette.inkMuted,
                  letterSpacing: 0.4,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: context.palette.ink,
                ),
              ),
              if (valueSecondLine != null && valueSecondLine!.isNotEmpty)
                Text(
                  valueSecondLine!,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: context.palette.inkMuted,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CheckCard extends StatelessWidget {
  const _CheckCard({
    required this.background,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.status,
    required this.body,
    required this.buttonLabel,
    required this.onPressed,
  });

  final Color background;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String status;
  final String body;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
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
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: context.palette.elevated,
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: context.palette.ink,
                      ),
                    ),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: context.palette.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            body,
            style: TextStyle(
              fontSize: 13.5,
              color: context.palette.inkMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Material(
            color: AppColors.blue,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              onTap: onPressed,
              child: Container(
                height: 52,
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      buttonLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
