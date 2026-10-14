import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/media/avatar.dart';
import '../../booking/domain/models/booking_selection.dart';

/// Blueprint view 12 — Doctor Profile ("Your clinician"). Shows only what the
/// directory holds: no photo, rating or biography is invented.
class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key, required this.selection});

  final BookingSelection selection;

  @override
  Widget build(BuildContext context) {
    final doctor = selection.doctor!;
    final formats = [for (final mode in doctor.modes) mode.label].join(', ');

    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const AppHeaderBar(showBack: true),
            const SizedBox(height: 20),
            const ScreenTitle(title: 'Your clinician'),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.palette.tintGreen,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Row(
                children: [
                  UserAvatar(name: doctor.name, radius: 32),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: context.palette.ink,
                          ),
                        ),
                        Text(
                          doctor.specialty,
                          style: TextStyle(
                            fontSize: 14,
                            color: context.palette.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (formats.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              _InfoRow(
                icon: Icons.videocam_outlined,
                iconColor: context.palette.accent,
                background: context.palette.tintBlue,
                title: 'Consultation formats',
                subtitle: formats,
              ),
            ],
            if (doctor.languages.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              _InfoRow(
                icon: Icons.public,
                iconColor: context.palette.positive,
                background: context.palette.tintGreen,
                title: 'Languages',
                subtitle: doctor.languages.join(', '),
              ),
            ],
            if (doctor.locationLabel != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _InfoRow(
                icon: Icons.location_on_outlined,
                iconColor: context.palette.accent,
                background: context.palette.tintBlue,
                title: 'Clinic location',
                subtitle: doctor.locationLabel!,
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.palette.tintBlue,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About your visit',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: context.palette.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Discuss your concern and agree next steps.',
                    style: TextStyle(
                      fontSize: 13,
                      color: context.palette.inkMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  PrimaryButton(
                    label: 'View appointment times',
                    icon: Icons.arrow_forward,
                    onPressed: () => context.push(
                      RoutePaths.bookingAppointmentTime,
                      extra: selection,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.background,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final Color background;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
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
                    fontSize: 13,
                    color: context.palette.inkMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
