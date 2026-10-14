import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../payer/domain/models/authorisation.dart';
import '../../payer/domain/models/eligibility_status.dart';
import '../../payment/domain/models/payment_status.dart';
import '../application/booking_controller.dart';
import '../domain/models/booking_status.dart';
import '../domain/models/consultation_mode.dart';

/// Blueprint view 17 — Booking Confirmation. Tells the truth about where the
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

    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const AppHeaderBar(showBack: true, backFallback: RoutePaths.visits),
            const SizedBox(height: AppSpacing.md),
            _StatusBanner(status: appointment.status, mode: appointment.mode),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                border: Border.all(color: context.palette.line),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: context.palette.tintBlue,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _modeIcon(appointment.mode),
                          color: context.palette.accent,
                          size: 20,
                        ),
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
                                color: context.palette.ink,
                              ),
                            ),
                            Text(
                              appointment.mode.consultationLabel,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: context.palette.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    child: Divider(height: 1, color: context.palette.line),
                  ),
                  _DetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Date',
                    value: Formatters.longDate(uk),
                  ),
                  _DetailRow(
                    icon: Icons.schedule_outlined,
                    label: 'Time',
                    value: '${Formatters.time(uk)} $zone',
                  ),
                  _DetailRow(
                    icon: Icons.person_outline,
                    label: 'With',
                    value: appointment.providerName,
                  ),
                  if (appointment.locationCity != null)
                    _DetailRow(
                      icon: Icons.location_on_outlined,
                      label: 'Where',
                      value: appointment.locationCity!,
                    ),
                  _DetailRow(
                    icon: Icons.badge_outlined,
                    label: 'Reference',
                    value: appointment.reference,
                  ),
                  _DetailRow(
                    icon: Icons.credit_card_outlined,
                    label: 'Payment',
                    value: paymentLabel,
                    isLast: true,
                  ),
                ],
              ),
            ),
            if (held) ...[
              const SizedBox(height: AppSpacing.md),
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
            const SizedBox(height: AppSpacing.md),
            _ActionRow(
              icon: Icons.fact_check_outlined,
              label: 'Prepare for your visit',
              filled: true,
              onTap: () =>
                  context.push(RoutePaths.appointmentCheck, extra: appointment),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ActionRow(
              icon: Icons.calendar_month_outlined,
              iconColor: context.palette.positive,
              label: 'Add to calendar',
              onTap: () =>
                  showComingSoonPopup(context, feature: 'Add to calendar'),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ActionRow(
              icon: Icons.receipt_long_outlined,
              iconColor: context.palette.accent,
              label: 'View receipt',
              onTap: () =>
                  showComingSoonPopup(context, feature: 'View receipt'),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ActionRow(
              icon: Icons.settings_outlined,
              iconColor: context.palette.positive,
              label: 'Manage booking',
              onTap: () => context.push(
                RoutePaths.manageAppointment,
                extra: appointment,
              ),
            ),
            if (confirmed && appointment.mode.isOnline) ...[
              const SizedBox(height: AppSpacing.md),
              const InfoBanner(
                icon: Icons.verified_user_outlined,
                title: 'Join from a private place',
                message:
                    'Choose a quiet, private location with a stable '
                    'internet connection.',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

IconData _modeIcon(ConsultationMode mode) => switch (mode) {
  ConsultationMode.video => Icons.videocam_outlined,
  ConsultationMode.audio => Icons.call_outlined,
  ConsultationMode.inPerson => Icons.apartment_outlined,
};

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.status, required this.mode});

  final BookingStatus status;
  final ConsultationMode mode;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final (background, color, icon, title, subtitle) = switch (status) {
      BookingStatus.confirmed => (
        palette.tintGreen,
        AppColors.greenStrong,
        Icons.check,
        'Appointment confirmed',
        'Your ${mode.consultationLabel.toLowerCase()} is booked.',
      ),
      BookingStatus.slotHeld => (
        palette.tintAmber,
        AppColors.gold,
        Icons.hourglass_top,
        'Waiting for confirmation',
        'Your ${mode.consultationLabel.toLowerCase()} is not booked yet.',
      ),
      BookingStatus.cancelled => (
        palette.tintRed,
        AppColors.error,
        Icons.close,
        'Appointment cancelled',
        'This booking was cancelled.',
      ),
      _ => (
        palette.tintBlue,
        AppColors.blue,
        Icons.info_outline,
        status.label,
        'Contact support if you need help with this booking.',
      ),
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.white, size: 22),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: palette.ink,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: palette.inkMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 18, color: context.palette.inkMuted),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: context.palette.inkMuted),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: context.palette.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A full-width tappable row used both for the primary "Prepare for your
/// visit" action and the secondary booking actions below it.
class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? AppColors.white : context.palette.ink;
    return Material(
      color: filled ? AppColors.blue : context.palette.elevated,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onTap,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: filled
              ? null
              : BoxDecoration(
                  border: Border.all(color: context.palette.line),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: filled ? fg : (iconColor ?? fg)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: fg,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, size: 20, color: fg),
            ],
          ),
        ),
      ),
    );
  }
}
