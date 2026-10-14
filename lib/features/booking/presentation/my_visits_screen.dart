import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/feedback/error_state.dart';
import '../../../core/widgets/feedback/loading_indicator.dart';
import '../../../core/widgets/layout/back_app_bar.dart';
import '../application/booking_controller.dart';
import '../domain/models/appointment.dart';
import '../domain/models/booking_status.dart';
import '../domain/models/consultation_mode.dart';

/// The Visits tab: the signed-in person's real appointments — upcoming first,
/// then past — read from the backend, with the way in to book another.
class MyVisitsScreen extends ConsumerWidget {
  const MyVisitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(appointmentsProvider);
    final notifier = ref.read(appointmentsProvider.notifier);

    return Scaffold(
      backgroundColor: context.palette.background,
      // A tab root, so the arrow goes Home.
      appBar: const BackAppBar(title: 'My visits'),
      body: SafeArea(
        child: all.when(
          loading: () => const LoadingIndicator(),
          error: (error, _) => all.hasValue
              ? _content(context, ref)
              : ErrorState(error: error, onRetry: notifier.refresh),
          data: (_) => _content(context, ref),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, WidgetRef ref) {
    final upcoming = ref.watch(upcomingAppointmentsProvider).value ?? const [];
    final past = ref.watch(pastAppointmentsProvider).value ?? const [];
    final notifier = ref.read(appointmentsProvider.notifier);

    return RefreshIndicator(
      onRefresh: notifier.refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          if (upcoming.isEmpty && past.isEmpty)
            const _NoVisits()
          else ...[
            if (upcoming.isNotEmpty) ...[
              const _SectionLabel('Upcoming'),
              for (final appointment in upcoming) ...[
                _VisitCard(appointment: appointment),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
            if (past.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              const _SectionLabel('Past'),
              for (final appointment in past) ...[
                _VisitCard(appointment: appointment),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ],
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            label: 'Book a consultation',
            onPressed: () => context.push(RoutePaths.chooseAccess),
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: TextButton.icon(
              onPressed: () => context.push(RoutePaths.findSmartGpClinic),
              icon: const Icon(Icons.apartment_outlined),
              label: const Text('Find a Smart GP clinic'),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoVisits extends StatelessWidget {
  const _NoVisits();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.calendar_today_outlined,
              color: context.palette.accent,
              size: 36,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No visits yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: context.palette.ink,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'When you book a consultation, it will show up here alongside '
            'your care plan and receipts.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: context.palette.inkMuted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: context.palette.ink,
        ),
      ),
    );
  }
}

class _VisitCard extends StatelessWidget {
  const _VisitCard({required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final uk = Formatters.ukTime(appointment.startsAt);
    final (statusLabel, statusColor) = _status(context);

    return Material(
      color: palette.tintBlue,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: () =>
            context.push(RoutePaths.manageAppointment, extra: appointment),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: palette.elevated,
                child: Icon(switch (appointment.mode) {
                  ConsultationMode.video => Icons.videocam_outlined,
                  ConsultationMode.audio => Icons.call_outlined,
                  ConsultationMode.inPerson => Icons.apartment_outlined,
                }, color: palette.accent),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.serviceName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: palette.ink,
                      ),
                    ),
                    Text(
                      'with ${appointment.providerName}',
                      style: TextStyle(fontSize: 12.5, color: palette.inkMuted),
                    ),
                    Text(
                      '${Formatters.dayLabel(DateTime(uk.year, uk.month, uk.day))}'
                      ', ${Formatters.time(uk)} '
                      '${Formatters.ukZoneLabel(appointment.startsAt)}',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: palette.ink,
                      ),
                    ),
                    if (statusLabel != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: palette.accent),
            ],
          ),
        ),
      ),
    );
  }

  /// What to say about the booking's state, if anything beyond its date.
  (String?, Color) _status(BuildContext context) {
    final palette = context.palette;
    if (appointment.isHoldExpired()) {
      return ('Not completed', palette.inkMuted);
    }
    return switch (appointment.status) {
      BookingStatus.confirmed =>
        appointment.isUpcoming()
            ? ('Confirmed', palette.positive)
            : (null, palette.inkMuted),
      BookingStatus.slotHeld => ('Awaiting confirmation', palette.warning),
      BookingStatus.cancelled => ('Cancelled', palette.danger),
      final other => (other.label, palette.inkMuted),
    };
  }
}
