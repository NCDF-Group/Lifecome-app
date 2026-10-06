import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/country/app_country.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_svg_icons.dart';
import '../../../core/widgets/design/soft_widgets.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../domain/booking_format.dart';
import '../domain/models/appointment.dart';

/// Blueprint view 17 — Booking Confirmation: "Online appointment confirmed"
/// or "Clinic appointment confirmed", with what the patient can do next.
class BookingConfirmationScreen extends ConsumerWidget {
  const BookingConfirmationScreen({super.key, required this.selection});

  final BookingSelection selection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inPerson = selection.isInPerson;
    final zone = timeZoneFor(ref.watch(countryProvider));
    final date = selection.date ?? DateTime.now();
    final city = selection.location ?? 'London';
    void comingSoon(String feature) =>
        showComingSoonPopup(context, feature: feature);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            DesignBackButton(onPressed: () => context.go(RoutePaths.home)),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFD9F9E3),
                  ),
                  child: const Center(
                    child: AppSvgIcon(
                      AppSvgGlyph.checkCircleBold,
                      size: 30,
                      color: Color(0xFF1B9C4A),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inPerson
                            ? 'Clinic appointment confirmed'
                            : 'Online appointment confirmed',
                        style: const TextStyle(
                          fontSize: 24,
                          height: 1.25,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Your appointment has been booked. You'll receive a "
                        'confirmation message.',
                        style: TextStyle(
                          fontSize: 14.5,
                          height: 1.4,
                          letterSpacing: -0.3,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            DetailRows(
              rows: [
                DetailRow(
                  glyph: inPerson
                      ? AppSvgGlyph.buildingBold
                      : AppSvgGlyph.videoBold,
                  label: 'Mode',
                  value: inPerson ? 'In-person' : 'Online',
                  sub: inPerson ? 'Clinic visit' : 'Video consultation',
                ),
                DetailRow(
                  glyph: AppSvgGlyph.calendarBold,
                  label: 'Date',
                  value: formatFullDate(date),
                ),
                DetailRow(
                  glyph: AppSvgGlyph.clockBold,
                  label: 'Time',
                  value: '${selection.time ?? '10:30'} ($zone)',
                ),
                if (inPerson)
                  DetailRow(
                    glyph: AppSvgGlyph.pinBold,
                    label: 'Location',
                    value: '$city clinic',
                    sub: 'View clinic address',
                    onSubTap: () => comingSoon('Clinic address'),
                  ),
                DetailRow(
                  glyph: AppSvgGlyph.stethoscope,
                  label: 'Clinician',
                  value: selection.doctor?.name ?? 'Your GP',
                  sub: selection.service?.title ?? 'GP consultation',
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (inPerson) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3FAEF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: const Row(
                  children: [
                    IconCircle(
                      glyph: AppSvgGlyph.checkCircleBold,
                      color: Color(0xFF1B9C4A),
                      fill: Color(0xFFD9F9E3),
                      size: 50,
                      iconSize: 26,
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Booking confirmed',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: Color(0xFF1B9C4A),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Your clinic appointment is confirmed.',
                            style: TextStyle(
                              fontSize: 15,
                              letterSpacing: -0.3,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ActionRow(
                glyph: AppSvgGlyph.documentBold,
                title: 'View visit instructions',
                onTap: () => comingSoon('Visit instructions'),
              ),
              const SizedBox(height: 12),
              ActionRow(
                glyph: AppSvgGlyph.pinBold,
                title: 'Get directions',
                onTap: () => comingSoon('Directions'),
              ),
              const SizedBox(height: 12),
              ActionRow(
                glyph: AppSvgGlyph.calendarPlusBold,
                title: 'Add to calendar',
                onTap: () => comingSoon('Add to calendar'),
              ),
            ] else ...[
              ActionRow(
                glyph: AppSvgGlyph.videoBold,
                title: 'Test camera and microphone',
                onTap: () => context.push(
                  RoutePaths.consultationWaitingRoom,
                  extra: selection,
                ),
              ),
              const SizedBox(height: 12),
              ActionRow(
                glyph: AppSvgGlyph.calendarPlusBold,
                title: 'Add to calendar',
                onTap: () => comingSoon('Add to calendar'),
              ),
              const SizedBox(height: 12),
              ActionRow(
                glyph: AppSvgGlyph.hexagonBold,
                title: 'Manage booking',
                onTap: () => context.push(RoutePaths.visits),
              ),
              const SizedBox(height: 24),
              ActionRow(
                soft: true,
                glyph: AppSvgGlyph.documentBold,
                title: 'View receipt',
                onTap: () => comingSoon('Receipts'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
