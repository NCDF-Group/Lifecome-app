import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/animation/fade_in.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_svg_icons.dart';
import '../../../core/widgets/design/soft_widgets.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../doctors/presentation/widgets/preferences_card.dart';
import '../application/booking_providers.dart';
import '../domain/models/appointment.dart';

/// "Smart GP locations" — the in-person clinics, each a photo card with the
/// same preference rows as Find a GP and a "Check appointment availability"
/// button. Reached from "How can we help?" when In Person is selected.
///
/// No clinic-directory backend exists yet, so the two locations are fixed and
/// availability is looked up against the sample doctors.
class SmartGpLocationsScreen extends StatelessWidget {
  const SmartGpLocationsScreen({super.key, required this.selection});

  final BookingSelection selection;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            const DesignBackButton(),
            const SizedBox(height: 14),
            const PageHeading(
              'Smart GP locations',
              subtitle:
                  'High-quality, convenient in-person care in your community.',
            ),
            const SizedBox(height: 22),
            FadeIn(
              delay: const Duration(milliseconds: 60),
              child: _LocationCard(
                selection: selection,
                name: 'London Smart GP',
                city: 'London',
                image: 'assets/images/home/smart-gp-london.jpg',
                chip: 'Check availability',
                chipColor: const Color(0xFFFBEFB4),
              ),
            ),
            const SizedBox(height: 24),
            FadeIn(
              delay: const Duration(milliseconds: 120),
              child: _LocationCard(
                selection: selection,
                name: 'Lagos Smart GP',
                city: 'Lagos',
                image: 'assets/images/home/smart-gp-city.jpg',
                chip: 'View location',
                chipColor: const Color(0xFFDDF0FC),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationCard extends ConsumerStatefulWidget {
  const _LocationCard({
    required this.selection,
    required this.name,
    required this.city,
    required this.image,
    required this.chip,
    required this.chipColor,
  });

  final BookingSelection selection;
  final String name;
  final String city;
  final String image;
  final String chip;
  final Color chipColor;

  @override
  ConsumerState<_LocationCard> createState() => _LocationCardState();
}

class _LocationCardState extends ConsumerState<_LocationCard> {
  String _mode = bookingModes.first;
  late String _location = widget.city;
  String _date = bookingDates.first;
  String _language = bookingLanguages.first;

  Future<void> _pick(
    String title,
    List<String> options,
    String current,
    ValueChanged<String> onPicked,
  ) async {
    final picked = await showOptionSheet(
      context,
      title: title,
      options: options,
      current: current,
    );
    if (picked != null) setState(() => onPicked(picked));
  }

  /// Picks a clinician who sees patients in person - preferring one based in the chosen city - and
  /// goes to their available times.
  Future<void> _checkAvailability() async {
    try {
      final doctors = await ref.read(doctorsProvider.future);
      final inPerson = doctors
          .where((doctor) => doctor.offersInPerson)
          .toList();
      if (inPerson.isEmpty) {
        if (mounted) {
          showErrorPopup(
            context,
            'No clinicians are offering in-person visits yet.',
          );
        }
        return;
      }
      final doctor = inPerson.firstWhere(
        (doctor) => doctor.city == _location,
        orElse: () => inPerson.first,
      );
      if (!mounted) return;
      context.push(
        RoutePaths.bookingAppointmentTime,
        extra: widget.selection.copyWith(
          doctor: doctor,
          consultationType: 'In-person visit',
          location: _location,
        ),
      );
    } on ApiException catch (error) {
      ref.invalidate(doctorsProvider);
      if (mounted) showErrorPopup(context, error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PreferencesCard(
      header: SizedBox(
        height: 150,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(widget.image, fit: BoxFit.cover),
            Positioned(
              left: 14,
              top: 15,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: AppColors.onIllustration,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: widget.chipColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.chip,
                        style: TextStyle(
                          fontSize: 14,
                          letterSpacing: -0.2,
                          color: AppColors.onIllustration,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      rows: [
        PrefRow(
          glyph: AppSvgGlyph.videoBold,
          label: 'Mode',
          value: _mode,
          onTap: () =>
              _pick('Mode', bookingModes, _mode, (value) => _mode = value),
        ),
        PrefRow(
          glyph: AppSvgGlyph.pinBold,
          label: 'Location',
          value: _location,
          onTap: () => _pick(
            'Location',
            bookingLocations,
            _location,
            (value) => _location = value,
          ),
        ),
        PrefRow(
          glyph: AppSvgGlyph.calendarBold,
          label: 'Preferred date',
          value: _date,
          onTap: () => _pick(
            'Preferred date',
            bookingDates,
            _date,
            (value) => _date = value,
          ),
        ),
        PrefRow(
          glyph: AppSvgGlyph.globeBold,
          label: 'Language preferences',
          value: _language,
          onTap: () => _pick(
            'Language preferences',
            bookingLanguages,
            _language,
            (value) => _language = value,
          ),
        ),
      ],
      footer: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: PillButton(
          label: 'Check appointment availability',
          height: 52,
          fontSize: 17,
          onPressed: _checkAvailability,
        ),
      ),
    );
  }
}
