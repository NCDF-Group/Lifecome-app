import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../domain/models/appointment.dart';
import '../domain/models/booking_status.dart';
import '../domain/models/consultation_mode.dart';

/// "Prepare for your visit" — what the booking is, what the care team has been
/// told, and what to have ready. Reached from the booking confirmation.
class AppointmentCheckScreen extends StatelessWidget {
  const AppointmentCheckScreen({super.key, required this.appointment});

  final Appointment appointment;

  List<String> get _tips => switch (appointment.mode) {
    ConsultationMode.video => const [
      'Find a quiet, private place with a stable internet connection.',
      'Have any medicines you take to hand.',
    ],
    ConsultationMode.audio => [
      appointment.intake?.callbackNumber == null
          ? 'Keep your phone nearby and switched on.'
          : 'Keep your phone nearby: your clinician will ring '
                '${appointment.intake!.callbackNumber}.',
      'Have any medicines you take to hand.',
    ],
    ConsultationMode.inPerson => const [
      'Bring any medicines you take.',
      'Tell the clinic if you need any support when you arrive.',
    ],
  };

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final uk = Formatters.ukTime(appointment.startsAt);
    final intake = appointment.intake;
    final details = <(String, String)>[
      if (intake?.reason != null) ('What you want to discuss', intake!.reason!),
      if (intake?.medicinesAndAllergies != null)
        ('Medicines and allergies', intake!.medicinesAndAllergies!),
      if (intake?.accessibilitySupport != null)
        ('Support you need', intake!.accessibilitySupport!),
      if (intake?.patientLocation != null)
        ('Where you will be', intake!.patientLocation!),
    ];

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const AppHeaderBar(showBack: true, backFallback: RoutePaths.visits),
            const SizedBox(height: 4),
            const ScreenTitle(
              title: 'Prepare for your visit',
              subtitle: 'A few things to know before your appointment.',
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: palette.tintBlue,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment.serviceName,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: palette.ink,
                    ),
                  ),
                  Text(
                    appointment.mode.consultationLabel,
                    style: TextStyle(fontSize: 13, color: palette.inkMuted),
                  ),
                  if (appointment.locationCity != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 15,
                            color: palette.inkMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            appointment.locationCity!,
                            style: TextStyle(
                              fontSize: 13,
                              color: palette.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    child: Divider(height: 1, color: palette.tintBlueLine),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _SummaryField(
                          icon: Icons.calendar_today_outlined,
                          label: 'DATE',
                          value: Formatters.date(uk),
                          second:
                              '${Formatters.time(uk)} '
                              '${Formatters.ukZoneLabel(appointment.startsAt)}',
                        ),
                      ),
                      Expanded(
                        child: _SummaryField(
                          icon: Icons.person_outline,
                          label: 'WITH',
                          value: appointment.providerName,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (appointment.status == BookingStatus.slotHeld) ...[
              const SizedBox(height: AppSpacing.md),
              const InfoBanner(
                tone: BannerTone.warning,
                message:
                    'This booking is not confirmed yet. It is confirmed as '
                    'soon as payment comes through.',
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            _Section(
              background: palette.tintGreen,
              icon: Icons.checklist_outlined,
              iconColor: palette.positive,
              title: 'Before you join',
              children: [
                for (final tip in _tips)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: palette.positive,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            tip,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: palette.ink,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _Section(
              background: palette.surface,
              icon: Icons.assignment_outlined,
              iconColor: palette.accent,
              title: 'What your clinician has been told',
              children: [
                if (details.isEmpty)
                  Text(
                    'No details were added to this booking.',
                    style: TextStyle(fontSize: 13.5, color: palette.inkMuted),
                  )
                else
                  for (final (label, value) in details)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 12,
                              color: palette.inkMuted,
                            ),
                          ),
                          Text(
                            value,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: palette.ink,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Material(
              color: palette.tintRed,
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.card),
                onTap: () => context.push(RoutePaths.emergency),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: palette.danger,
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
                                color: palette.danger,
                              ),
                            ),
                            Text(
                              'View emergency guidance.',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: palette.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: palette.danger),
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
}

class _SummaryField extends StatelessWidget {
  const _SummaryField({
    required this.icon,
    required this.label,
    required this.value,
    this.second,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? second;

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
              if (second != null)
                Text(
                  second!,
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

class _Section extends StatelessWidget {
  const _Section({
    required this.background,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.children,
  });

  final Color background;
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<Widget> children;

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
                radius: 18,
                backgroundColor: context.palette.elevated,
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.palette.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...children,
        ],
      ),
    );
  }
}
