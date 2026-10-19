import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/buttons/secondary_button.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/feedback/status_chip.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/detail_list.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/lists/row_card.dart';
import '../../../core/widgets/media/lc_icons.dart';
import '../../payer/domain/models/authorisation.dart';
import '../../payer/domain/models/eligibility_status.dart';
import '../../payment/domain/models/payment_status.dart';
import '../application/booking_controller.dart';
import '../domain/models/booking_status.dart';

/// Booking confirmation (screen pack 049). Tells the truth about where the
/// booking is: confirmed, or still waiting for payment to come through.
class BookingConfirmationScreen extends ConsumerWidget {
  const BookingConfirmationScreen({super.key, required this.outcome});

  final BookingOutcome outcome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The list is refreshed from the backend (by "Check status"); prefer its
    // copy of this appointment over the one from the moment of booking.
    final latest = ref
        .watch(appointmentsProvider)
        .value
        ?.where((item) => item.id == outcome.appointment.id)
        .firstOrNull;
    final appointment = latest ?? outcome.appointment;
    final confirmed = appointment.status == BookingStatus.confirmed;
    final held = appointment.status == BookingStatus.slotHeld;
    final payment = outcome.payment;
    final uk = Formatters.ukTime(appointment.startsAt);
    final zone = Formatters.ukZoneLabel(appointment.startsAt);

    final plan = outcome.planName;
    final check = outcome.eligibility;
    final authorisation = outcome.authorisation;

    final String paymentLabel;
    if (plan != null) {
      paymentLabel = switch ((check?.status, authorisation?.status)) {
        (_, AuthorisationStatus.approved) => 'Approved by $plan',
        (_, AuthorisationStatus.pending) => 'Waiting for $plan to approve',
        (_, AuthorisationStatus.moreInfoRequired) =>
          '$plan needs more information',
        (_, AuthorisationStatus.declined) => 'Declined by $plan',
        (EligibilityStatus.coPay, _) when check?.coPayMinor != null =>
          'Covered by $plan · co-pay ${Formatters.money(check!.coPayMinor!)}',
        (EligibilityStatus.covered, _) => 'Covered by $plan',
        _ => plan,
      };
    } else {
      paymentLabel = switch (appointment.fundingRoute.apiValue) {
        'pay_per_visit' when payment != null && payment.isPaid =>
          'Paid ${Formatters.money(payment.amountMinor)}',
        'pay_per_visit' when payment != null =>
          '${Formatters.money(payment.amountMinor)} · '
              '${payment.status == PaymentStatus.failed ? 'payment failed' : 'awaiting payment'}',
        _ => appointment.fundingRoute.label,
      };
    }

    final (title, subtitle, badge) = switch (appointment.status) {
      BookingStatus.confirmed => (
        "You're booked in",
        'Your ${appointment.mode.consultationLabel.toLowerCase()} has been '
            'added to Visits.',
        const StatusBadge('Confirmed'),
      ),
      BookingStatus.slotHeld => (
        'Waiting for confirmation',
        'Your ${appointment.mode.consultationLabel.toLowerCase()} is not '
            'booked yet.',
        const StatusBadge('Waiting', tone: BadgeTone.amber),
      ),
      BookingStatus.cancelled => (
        'Appointment cancelled',
        'This booking was cancelled.',
        const StatusBadge('Cancelled', tone: BadgeTone.gray),
      ),
      final other => (
        other.label,
        'Contact support if you need help with this booking.',
        StatusBadge(other.label, tone: BadgeTone.blue),
      ),
    };

    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 25),
          children: [
            const AppHeaderBar(showBack: true, backFallback: RoutePaths.visits),
            if (confirmed) const SuccessIcon() else const SizedBox(height: 18),
            ScreenTitle(title: title, subtitle: subtitle),
            const SizedBox(height: 12),
            badge,
            const SizedBox(height: 8),
            DetailList(
              rows: [
                ('Service', appointment.serviceName),
                ('Appointment', appointment.mode.consultationLabel),
                ('Clinician', appointment.providerName),
                ('Date', Formatters.longDate(uk)),
                ('Time', '${Formatters.time(uk)} · UK time ($zone)'),
                if (appointment.locationCity != null)
                  ('Location', appointment.locationCity!),
                ('Reference', appointment.reference),
                ('Payment', paymentLabel),
              ],
            ),
            if (held) ...[
              const SizedBox(height: 10),
              InfoBanner(
                tone: BannerTone.warning,
                title: 'Your time is being held',
                message: plan == null
                    ? "We'll hold this time for 10 minutes. Your booking is "
                          'confirmed as soon as payment comes through, and '
                          "we'll send you a notification."
                    : "We'll hold this time while $plan approves your visit. "
                          "You'll get a notification as soon as it is "
                          'confirmed.',
                actionLabel: 'Check status',
                onAction: () =>
                    ref.read(appointmentsProvider.notifier).refresh(),
              ),
            ],
            if (confirmed && appointment.mode.isOnline) ...[
              const SizedBox(height: 10),
              const InfoBanner(
                icon: Icons.verified_user_outlined,
                title: 'Join from a private place',
                message:
                    'Choose a quiet, private location with a stable '
                    'internet connection.',
              ),
            ],
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'View appointment',
              onPressed: () => context.push(
                RoutePaths.manageAppointment,
                extra: appointment,
              ),
            ),
            const SizedBox(height: 4),
            RowCard(
              icon: LcIcons.check,
              title: 'Prepare for your visit',
              subtitle:
                  'What your clinician has been told and what to have '
                  'ready',
              tone: RowCardTone.mint,
              onTap: () =>
                  context.push(RoutePaths.appointmentCheck, extra: appointment),
            ),
            const SizedBox(height: 6),
            SecondaryButton(
              label: 'Return home',
              onPressed: () => context.go(RoutePaths.home),
            ),
          ],
        ),
      ),
    );
  }
}
