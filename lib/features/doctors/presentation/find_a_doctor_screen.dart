import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/country/app_country.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_svg_icons.dart';
import '../../../core/widgets/design/soft_widgets.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../booking/application/booking_providers.dart';
import '../../booking/domain/models/appointment.dart';
import '../domain/models/doctor.dart';
import 'widgets/preferences_card.dart';

/// "Find a GP" — set preferences (mode, location, date, language), jump to
/// the next suitable appointment, or search for a particular clinician.
///
/// No provider-directory backend exists yet, so this filters the static
/// `sampleDoctors` list; mode, location and date are collected for the
/// booking but don't narrow it.
class FindADoctorScreen extends ConsumerStatefulWidget {
  const FindADoctorScreen({super.key, required this.selection});

  final BookingSelection selection;

  @override
  ConsumerState<FindADoctorScreen> createState() => _FindADoctorScreenState();
}

class _FindADoctorScreenState extends ConsumerState<FindADoctorScreen> {
  String _query = '';
  late String _mode = widget.selection.consultationType == 'In-person visit'
      ? 'In person'
      : bookingModes.first;
  String? _location;
  String _date = bookingDates.first;
  String _language = bookingLanguages.first;

  String get _locationOrDefault =>
      _location ??
      (ref.read(countryProvider) == AppCountry.unitedKingdom
          ? 'London'
          : 'Lagos');

  BookingSelection get _selection => widget.selection.copyWith(
    location: _locationOrDefault,
    consultationType: _mode == 'In person'
        ? 'In-person visit'
        : 'Video consultation',
  );

  List<Doctor> _filter(List<Doctor> doctors) => doctors.where((doctor) {
    final query = _query.trim().toLowerCase();
    final matchesQuery =
        query.isEmpty ||
        doctor.name.toLowerCase().contains(query) ||
        doctor.specialty.toLowerCase().contains(query);
    final matchesLanguage =
        _language == bookingLanguages.first ||
        doctor.languages.contains(_language);
    final matchesMode = switch (_mode) {
      'In person' => doctor.offersInPerson,
      'Online' => doctor.offersOnline,
      _ => true, // "Online or clinic"
    };
    return matchesQuery && matchesLanguage && matchesMode;
  }).toList();

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

  void _viewAppointments(List<Doctor> doctors) {
    final results = _filter(doctors);
    if (results.isEmpty) {
      showErrorPopup(
        context,
        'No clinicians match those preferences. Try a different language.',
      );
      return;
    }
    context.push(
      RoutePaths.bookingAppointmentTime,
      extra: _selection.copyWith(doctor: results.first),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doctorsAsync = ref.watch(doctorsProvider);
    final doctors = doctorsAsync.value ?? const <Doctor>[];
    final results = _filter(doctors);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            const DesignBackButton(),
            const SizedBox(height: 14),
            const PageHeading(
              'Find a GP',
              subtitle:
                  'Choose your preferences to find a suitable appointment.',
            ),
            const SizedBox(height: 22),
            PreferencesCard(
              rows: [
                PrefRow(
                  glyph: AppSvgGlyph.videoBold,
                  label: 'Mode',
                  value: _mode,
                  onTap: () => _pick(
                    'Mode',
                    bookingModes,
                    _mode,
                    (value) => _mode = value,
                  ),
                ),
                PrefRow(
                  glyph: AppSvgGlyph.pinBold,
                  label: 'Location',
                  value: _locationOrDefault,
                  onTap: () => _pick(
                    'Location',
                    bookingLocations,
                    _locationOrDefault,
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
            ),
            const SizedBox(height: 28),
            SoftCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Row(
                    children: [
                      IconCircle(glyph: AppSvgGlyph.calendarBold),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Next suitable appointment',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'See available times based on your preferences.',
                              style: TextStyle(
                                fontSize: 13,
                                letterSpacing: -0.2,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  PillButton(
                    label: 'View appointments',
                    onPressed: doctorsAsync.isLoading
                        ? null
                        : () => _viewAppointments(doctors),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Prefer a particular clinician?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Search by name to find a clinician and view their availability.',
              style: TextStyle(
                fontSize: 13.5,
                letterSpacing: -0.2,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) => setState(() => _query = value),
              style: const TextStyle(
                fontSize: 17,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search by name',
                hintStyle: const TextStyle(
                  fontSize: 17,
                  color: AppColors.textSecondary,
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(14),
                  child: AppSvgIcon(
                    AppSvgGlyph.searchLine,
                    size: 24,
                    color: AppColors.textSecondary,
                  ),
                ),
                filled: true,
                fillColor: const Color(0xFFF5F7F9),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: _border(AppColors.cardBorder),
                enabledBorder: _border(AppColors.cardBorder),
                focusedBorder: _border(AppColors.actionBlue),
              ),
            ),
            const SizedBox(height: 20),
            if (doctorsAsync.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (doctorsAsync.hasError)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: TextButton(
                    onPressed: () => ref.invalidate(doctorsProvider),
                    child: const Text(
                      "Couldn't load clinicians. Tap to retry.",
                    ),
                  ),
                ),
              )
            else if (results.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No clinicians found.',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            for (final doctor in results) ...[
              _DoctorEntry(
                doctor: doctor,
                onViewProfile: () => context.push(
                  RoutePaths.doctorsProfile,
                  extra: _selection.copyWith(doctor: doctor),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  static OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: color),
  );
}

class _DoctorEntry extends StatelessWidget {
  const _DoctorEntry({required this.doctor, required this.onViewProfile});

  final Doctor doctor;
  final VoidCallback onViewProfile;

  @override
  Widget build(BuildContext context) {
    final role = doctor.specialty.contains('General') ? 'GP' : doctor.specialty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            ClipOval(
              child: Image.asset(
                'assets/images/home/doctor-avatar.png',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 18,
                    runSpacing: 4,
                    children: [
                      _Chip(glyph: AppSvgGlyph.userLine, label: role),
                      const _Chip(glyph: AppSvgGlyph.videoLine, label: 'Video'),
                      const _Chip(
                        glyph: AppSvgGlyph.pinLine,
                        label: 'In person',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        PillButton(label: 'View Profile', onPressed: onViewProfile),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.glyph, required this.label});

  final AppSvgGlyph glyph;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppSvgIcon(glyph, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            letterSpacing: -0.2,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
