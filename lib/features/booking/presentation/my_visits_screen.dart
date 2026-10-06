import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/country/app_country.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_svg_icons.dart';
import '../../../core/widgets/design/soft_widgets.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../application/booking_providers.dart';
import '../domain/booking_format.dart';
import '../domain/models/my_appointment.dart';

/// My visits: the patient's real appointments from the backend - upcoming first, then past and
/// cancelled - with a way to cancel one that hasn't happened yet.
class MyVisitsScreen extends ConsumerWidget {
  const MyVisitsScreen({super.key});

  Future<void> _cancel(
    BuildContext context,
    WidgetRef ref,
    MyAppointment visit,
  ) async {
    final confirmed = await showConfirmPopup(
      context,
      title: 'Cancel this appointment?',
      message: 'Your time with ${visit.providerName} will be released.',
      confirmLabel: 'Cancel appointment',
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    try {
      await ref.read(bookingRepositoryProvider).cancel(visit.id);
      ref.invalidate(myAppointmentsProvider);
    } on ApiException catch (error) {
      if (context.mounted) showErrorPopup(context, error.message);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visits = ref.watch(myAppointmentsProvider);
    final country = ref.watch(countryProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(myAppointmentsProvider.future),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: [
              const DesignBackButton(),
              const SizedBox(height: 14),
              const PageHeading(
                'My visits',
                subtitle: 'Your upcoming and past appointments.',
              ),
              const SizedBox(height: 22),
              ...visits.when(
                loading: () => const [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
                error: (error, _) => [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: TextButton(
                        onPressed: () => ref.invalidate(myAppointmentsProvider),
                        child: const Text(
                          "Couldn't load your visits. Tap to retry.",
                        ),
                      ),
                    ),
                  ),
                ],
                data: (all) {
                  if (all.isEmpty) return [const _Empty()];
                  final upcoming = all.where((v) => v.isUpcoming).toList()
                    ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
                  final past = all.where((v) => !v.isUpcoming).toList();
                  return [
                    if (upcoming.isNotEmpty) ...[
                      const _SectionTitle('Upcoming'),
                      for (final visit in upcoming)
                        _VisitCard(
                          visit: visit,
                          country: country,
                          onCancel: () => _cancel(context, ref, visit),
                        ),
                    ],
                    if (past.isNotEmpty) ...[
                      const _SectionTitle('Past and cancelled'),
                      for (final visit in past)
                        _VisitCard(visit: visit, country: country),
                    ],
                  ];
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 12),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: Color(0xFF0B101A),
      ),
    ),
  );
}

class _VisitCard extends StatelessWidget {
  const _VisitCard({required this.visit, required this.country, this.onCancel});

  final MyAppointment visit;
  final AppCountry country;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final local = zonedTime(visit.startsAt, country);
    final when =
        '${formatFullDate(DateTime(local.year, local.month, local.day))} · '
        '${formatClock(visit.startsAt, country)}';
    final status = switch (visit.status) {
      'confirmed' => 'Confirmed',
      'slot_held' => 'Awaiting payment',
      'cancelled' => 'Cancelled',
      'patient_no_show' => 'Missed',
      'doctor_unavailable' => 'Clinician unavailable',
      _ => visit.status,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SoftCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconCircle(
                  glyph: visit.isInPerson
                      ? AppSvgGlyph.buildingBold
                      : AppSvgGlyph.videoBold,
                  size: 48,
                  iconSize: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visit.serviceName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'with ${visit.providerName}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: visit.isCancelled
                        ? AppColors.alertRed
                        : AppColors.actionBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              when,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (visit.isInPerson && visit.locationCity != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  visit.clinicName ?? '${visit.locationCity} Smart GP',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            if (onCancel != null) ...[
              const SizedBox(height: 12),
              PillButton(
                label: 'Cancel appointment',
                outlined: true,
                showChevron: false,
                height: 44,
                fontSize: 15,
                onPressed: onCancel,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        const Text(
          'No visits yet',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Your booked appointments will appear here.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),
        PillButton(
          label: 'Book an appointment',
          expand: false,
          onPressed: () => context.go(RoutePaths.book),
        ),
      ],
    );
  }
}
