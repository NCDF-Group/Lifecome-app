import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/feedback/empty_state.dart';
import '../../../core/widgets/feedback/error_state.dart';
import '../../../core/widgets/feedback/loading_indicator.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../doctors/application/doctor_search_controller.dart';
import '../../doctors/domain/models/doctor.dart';
import '../domain/models/booking_selection.dart';
import '../domain/models/consultation_mode.dart';

/// "Find a Smart GP clinic" — the clinicians who see patients in person, from
/// the backend's directory, narrowed by what the person types.
class FindSmartGpClinicScreen extends ConsumerStatefulWidget {
  const FindSmartGpClinicScreen({super.key});

  @override
  ConsumerState<FindSmartGpClinicScreen> createState() =>
      _FindSmartGpClinicScreenState();
}

class _FindSmartGpClinicScreenState
    extends ConsumerState<FindSmartGpClinicScreen> {
  final _searchController = TextEditingController();
  String _query = '';

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

    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const AppHeaderBar(showBack: true, backFallback: RoutePaths.visits),
            const SizedBox(height: 20),
            const ScreenTitle(
              title: 'Find a Smart GP clinic',
              subtitle:
                  'Search for a clinic near you and book an appointment in '
                  'person.',
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onChanged: (value) => setState(() => _query = value),
              style: TextStyle(fontSize: 16, color: context.palette.ink),
              decoration: InputDecoration(
                hintText: 'Search by town, city or clinician',
                errorText: searchError,
                prefixIcon: Icon(Icons.search, color: context.palette.inkMuted),
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
            const SizedBox(height: AppSpacing.md),
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
                            RoutePaths.bookingChooseService,
                            extra: const BookingStart.direct(),
                          )
                        : null,
                  );
                }
                return Column(
                  children: [
                    for (var i = 0; i < clinics.length; i++) ...[
                      _ClinicCard(
                        doctor: clinics[i],
                        green: i.isEven,
                        onBook: () => context.push(
                          RoutePaths.bookingChooseService,
                          extra: BookingStart.direct(doctor: clinics[i]),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.xs),
            Material(
              color: context.palette.tintBlue,
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.card),
                onTap: () => context.go(RoutePaths.messages),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: context.palette.elevated,
                        child: Icon(
                          Icons.chat_bubble_outline,
                          color: context.palette.accent,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Need help choosing?',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: context.palette.ink,
                              ),
                            ),
                            Text(
                              'Message the care team.',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: context.palette.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: context.palette.accent),
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

class _ClinicCard extends StatelessWidget {
  const _ClinicCard({
    required this.doctor,
    required this.green,
    required this.onBook,
  });

  final Doctor doctor;
  final bool green;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: green ? palette.tintGreen : palette.tintBlue,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: palette.elevated,
                child: Icon(
                  Icons.apartment_outlined,
                  color: green ? palette.positive : palette.accent,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.locationLabel ?? 'Smart GP clinic',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: palette.ink,
                      ),
                    ),
                    Text(
                      '${doctor.name} · ${doctor.specialty}',
                      style: TextStyle(fontSize: 12.5, color: palette.inkMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(
            label: 'Book an appointment',
            icon: Icons.arrow_forward,
            onPressed: onBook,
          ),
        ],
      ),
    );
  }
}
