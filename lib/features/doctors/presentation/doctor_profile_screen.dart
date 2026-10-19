import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/router/safe_back.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/buttons/secondary_button.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/detail_list.dart';
import '../../../core/widgets/media/avatar.dart';
import '../../booking/domain/models/booking_selection.dart';

/// A clinician's profile (screen pack 041). Shows only what the directory
/// holds: no photo, rating or biography is invented.
class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key, required this.selection});

  final BookingSelection selection;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final doctor = selection.doctor!;
    final formats = [for (final mode in doctor.modes) mode.label].join(', ');

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 25),
          children: [
            const AppHeaderBar(showBack: true, backFallback: RoutePaths.gp),
            const SizedBox(height: 10),
            Center(child: UserAvatar(name: doctor.name, radius: 39)),
            const SizedBox(height: 15),
            Text(
              doctor.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.6,
                color: palette.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              doctor.specialty,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: palette.inkMuted),
            ),
            const SizedBox(height: 14),
            const PanelCard(
              title: 'About your visit',
              body:
                  'Discuss your concern with your clinician and agree the '
                  'next steps together.',
              tone: PanelTone.mint,
            ),
            DetailList(
              rows: [
                if (formats.isNotEmpty) ('Appointment types', formats),
                if (doctor.languages.isNotEmpty)
                  ('Languages', doctor.languages.join(', ')),
                if (doctor.locationLabel != null)
                  ('Clinic location', doctor.locationLabel!),
              ],
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Choose a time',
              onPressed: () => context.push(
                RoutePaths.bookingAppointmentTime,
                extra: selection,
              ),
            ),
            const SizedBox(height: 10),
            SecondaryButton(
              label: 'See other GPs',
              onPressed: () => context.goBack(fallback: RoutePaths.gp),
            ),
          ],
        ),
      ),
    );
  }
}
