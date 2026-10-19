import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/feedback/empty_state.dart';
import '../../../core/widgets/feedback/error_state.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/feedback/loading_indicator.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/detail_list.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/lists/row_card.dart';
import '../../../core/widgets/lists/timeline_item.dart';
import '../../../core/widgets/media/lc_icons.dart';
import '../../doctors/application/doctor_search_controller.dart';
import '../../doctors/domain/models/doctor.dart';
import '../domain/models/booking_selection.dart';
import '../domain/models/consultation_mode.dart';

/// "Visit a GP in person" (screen pack 043) — the clinicians who see patients
/// in person, from the backend's directory, narrowed by what the person
/// types. Reached from the eligibility step (with a [start] carrying where
/// they want a clinic) or from Visits.
class FindSmartGpClinicScreen extends ConsumerStatefulWidget {
  const FindSmartGpClinicScreen({super.key, this.start});

  final BookingStart? start;

  @override
  ConsumerState<FindSmartGpClinicScreen> createState() =>
      _FindSmartGpClinicScreenState();
}

class _FindSmartGpClinicScreenState
    extends ConsumerState<FindSmartGpClinicScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  BookingStart get _start =>
      widget.start ??
      const BookingStart.direct(mode: ConsultationMode.inPerson);

  @override
  void initState() {
    super.initState();
    final city = widget.start?.city;
    if (city != null) {
      _searchController.text = city;
      _query = city;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matches(Doctor doctor) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return true;
    return [
      doctor.city,
      doctor.state,
      doctor.name,
    ].whereType<String>().any((text) => text.toLowerCase().contains(query));
  }

  @override
  Widget build(BuildContext context) {
    final doctors = ref.watch(doctorsProvider);
    final searchError = Validators.searchQuery(_query);
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 25),
          children: [
            AppHeaderBar(
              showBack: true,
              backFallback: widget.start == null
                  ? RoutePaths.visits
                  : RoutePaths.gp,
            ),
            const SizedBox(height: 4),
            const ScreenTitle(
              title: 'Visit a GP in person',
              subtitle: 'Find a clinic near you and book an appointment.',
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onChanged: (value) => setState(() => _query = value),
              style: TextStyle(fontSize: 15, color: palette.ink),
              decoration: InputDecoration(
                hintText: 'Search town, city or clinician',
                errorText: searchError,
                filled: true,
                fillColor: palette.surface,
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: LcIcon(
                    LcIcons.search,
                    size: 18,
                    color: palette.inkMuted,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.control),
                  borderSide: BorderSide(color: palette.line),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.control),
                  borderSide: BorderSide(color: palette.accent),
                ),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear',
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
            ),
            const SizedBox(height: 10),
            doctors.when(
              loading: () => const LoadingIndicator(),
              error: (error, _) => ErrorState(
                error: error,
                onRetry: () => ref.invalidate(doctorsProvider),
              ),
              data: (all) {
                final clinics = [
                  for (final doctor in all)
                    if (doctor.offers(ConsultationMode.inPerson) &&
                        _matches(doctor))
                      doctor,
                ];
                if (clinics.isEmpty) {
                  final nothingYet = all.every(
                    (doctor) => !doctor.offers(ConsultationMode.inPerson),
                  );
                  return EmptyState(
                    icon: Icons.apartment_outlined,
                    title: nothingYet
                        ? 'No clinics yet'
                        : 'No clinics match your search',
                    message: nothingYet
                        ? 'In-person appointments are not available yet. You '
                              'can still book an online appointment.'
                        : 'Try a different town or city.',
                    actionLabel: nothingYet
                        ? 'Book an online appointment'
                        : null,
                    onAction: nothingYet
                        ? () => context.push(
                            RoutePaths.gpEligibility,
                            extra: const BookingStart.direct(
                              mode: ConsultationMode.video,
                            ),
                          )
                        : null,
                  );
                }
                return Column(
                  children: [
                    for (final clinic in clinics)
                      RowCard(
                        icon: LcIcons.clinic,
                        title: clinic.locationLabel ?? 'Smart GP clinic',
                        subtitle: '${clinic.name} · ${clinic.specialty}',
                        tone: RowCardTone.white,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ClinicDetailScreen(
                              doctor: clinic,
                              start: _start,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 6),
            RowCard(
              icon: LcIcons.message,
              title: 'Need help choosing?',
              subtitle: 'Message the care team',
              onTap: () => context.go(RoutePaths.messages),
            ),
          ],
        ),
      ),
    );
  }
}

/// One clinic (screen pack 044): where it is, who sees patients there, what
/// to bring, and the way to book. Only what the directory holds is shown —
/// no invented opening hours or facilities.
class ClinicDetailScreen extends StatelessWidget {
  const ClinicDetailScreen({
    super.key,
    required this.doctor,
    required this.start,
  });

  final Doctor doctor;
  final BookingStart start;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 25),
          children: [
            const AppHeaderBar(showBack: true, backFallback: RoutePaths.gp),
            const SizedBox(height: 4),
            ScreenTitle(
              title: doctor.locationLabel ?? 'Smart GP clinic',
              subtitle: 'In-person GP appointments',
            ),
            const SizedBox(height: 16),
            Container(
              height: 145,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [palette.tintGreen, palette.tintBlue],
                ),
              ),
              alignment: Alignment.center,
              child: LcIcon(LcIcons.pin, size: 42, color: palette.accent),
            ),
            const SizedBox(height: 8),
            DetailList(
              rows: [
                ('Clinician', doctor.name),
                ('Specialty', doctor.specialty),
                if (doctor.locationLabel != null)
                  ('Location', doctor.locationLabel!),
                ('Appointment', 'In-person GP consultation'),
              ],
            ),
            const CheckList(
              items: [
                'Bring photo identification',
                'Bring a list of current medicines',
                'Arrive before your appointment time',
              ],
            ),
            const InfoBanner(
              message: 'The full address is in your booking confirmation.',
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Choose a clinic appointment',
              onPressed: () => context.push(
                RoutePaths.bookingChooseService,
                extra: start.withDoctor(doctor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
