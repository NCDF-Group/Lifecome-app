import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_svg_icons.dart';
import '../../../core/widgets/design/soft_widgets.dart';
import '../../booking/domain/models/appointment.dart';

/// Blueprint view 12 - Doctor Profile: who the clinician is and how they see patients.
/// Shows only what the provider directory actually holds (name, specialty, base, languages and
/// the kinds of appointment they offer).
class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key, required this.selection});

  final BookingSelection selection;

  @override
  Widget build(BuildContext context) {
    final doctor = selection.doctor!;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            const DesignBackButton(),
            const SizedBox(height: 14),
            Center(
              child: ClipOval(
                child: Image.asset(
                  'assets/images/home/doctor-avatar.png',
                  width: 96,
                  height: 96,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: Text(
                doctor.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                doctor.city == null
                    ? doctor.specialty
                    : '${doctor.specialty} · ${doctor.city}',
                style: const TextStyle(
                  fontSize: 15,
                  letterSpacing: -0.3,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 26),
            DetailRows(
              rows: [
                if (doctor.languages.isNotEmpty)
                  DetailRow(
                    glyph: AppSvgGlyph.globeBold,
                    label: 'Languages',
                    value: doctor.languages.join(', '),
                  ),
                DetailRow(
                  glyph: AppSvgGlyph.videoBold,
                  label: 'Appointments',
                  value: [
                    if (doctor.offersOnline) 'Online',
                    if (doctor.offersInPerson) 'In person',
                  ].join(' and '),
                ),
                if (doctor.city != null)
                  DetailRow(
                    glyph: AppSvgGlyph.pinBold,
                    label: 'Based in',
                    value: doctor.city!,
                  ),
              ],
            ),
            const SizedBox(height: 24),
            PillButton(
              label: 'Choose appointment time',
              height: 54,
              onPressed: () => context.push(
                RoutePaths.bookingAppointmentTime,
                extra: selection,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
