import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/router/safe_back.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../application/booking_controller.dart';
import '../domain/models/appointment.dart';
import '../domain/models/booking_status.dart';
import '../domain/models/consultation_mode.dart';

/// "Manage appointment" — one booking's summary, with what can be done to it:
/// join the waiting room, cancel it, or get help.
class ManageAppointmentScreen extends ConsumerStatefulWidget {
  const ManageAppointmentScreen({super.key, required this.appointment});

  final Appointment appointment;

  @override
  ConsumerState<ManageAppointmentScreen> createState() =>
      _ManageAppointmentScreenState();
}

class _ManageAppointmentScreenState
    extends ConsumerState<ManageAppointmentScreen> {
  bool _cancelling = false;

  Appointment get _current =>
      ref
          .watch(appointmentsProvider)
          .value
          ?.where((item) => item.id == widget.appointment.id)
          .firstOrNull ??
      widget.appointment;

  Future<void> _cancel(Appointment appointment) async {
    final confirmed = await showConfirmPopup(
      context,
      title: 'Cancel this appointment?',
      message:
          'Your ${appointment.serviceName.toLowerCase()} with '
          '${appointment.providerName} on '
          '${Formatters.appointmentWhen(appointment.startsAt)} will be '
          'cancelled and the time released.',
      confirmLabel: 'Cancel appointment',
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    setState(() => _cancelling = true);
    try {
      await ref.read(appointmentsProvider.notifier).cancel(appointment);
      if (!mounted) return;
      await showSuccessPopup(
        context,
        title: 'Appointment cancelled',
        message: 'Your appointment has been cancelled.',
      );
      if (mounted) context.go(RoutePaths.visits);
    } on ApiException catch (error) {
      if (mounted) await showErrorPopup(context, error.message);
    } catch (_) {
      if (mounted) {
        await showErrorPopup(
          context,
          'Something went wrong. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointment = _current;
    final canJoin =
        appointment.status == BookingStatus.confirmed &&
        appointment.mode.isOnline &&
        appointment.endsAt.isAfter(DateTime.now());
    final canCancel =
        appointment.status.isCancellable &&
        appointment.endsAt.isAfter(DateTime.now());

    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const AppHeaderBar(showBack: true, backFallback: RoutePaths.visits),
            const SizedBox(height: 20),
            const ScreenTitle(
              title: 'Manage appointment',
              subtitle: 'Join, cancel or get help with your appointment.',
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.palette.tintBlue,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: context.palette.elevated,
                    child: Icon(switch (appointment.mode) {
                      ConsultationMode.video => Icons.videocam_outlined,
                      ConsultationMode.audio => Icons.call_outlined,
                      ConsultationMode.inPerson => Icons.apartment_outlined,
                    }, color: context.palette.accent),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.serviceName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: context.palette.ink,
                          ),
                        ),
                        Text(
                          'with ${appointment.providerName}',
                          style: TextStyle(
                            fontSize: 13,
                            color: context.palette.inkMuted,
                          ),
                        ),
                        Text(
                          '${Formatters.appointmentWhen(appointment.startsAt)} '
                          '${Formatters.ukZoneLabel(appointment.startsAt)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: context.palette.inkMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appointment.status.label,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: appointment.status == BookingStatus.confirmed
                                ? context.palette.positive
                                : context.palette.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (canJoin) ...[
              _ActionRow(
                icon: Icons.meeting_room_outlined,
                background: context.palette.tintGreen,
                iconColor: context.palette.positive,
                title: 'Go to your waiting room',
                subtitle: 'Check in for your appointment.',
                onTap: () => context.push(
                  RoutePaths.consultationWaitingRoom,
                  extra: appointment,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (canCancel) ...[
              _ActionRow(
                icon: Icons.calendar_month_outlined,
                background: context.palette.tintGreen,
                iconColor: context.palette.positive,
                title: 'Reschedule appointment',
                subtitle: 'Choose a new date or time.',
                onTap: () => showComingSoonPopup(
                  context,
                  feature: 'Rescheduling an appointment',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _ActionRow(
                icon: Icons.delete_outline,
                background: context.palette.tintRed,
                iconColor: context.palette.danger,
                title: 'Cancel appointment',
                subtitle: 'Cancel this booking and release the time.',
                busy: _cancelling,
                onTap: () => _cancel(appointment),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            _ActionRow(
              icon: Icons.description_outlined,
              background: context.palette.tintBlue,
              iconColor: context.palette.accent,
              title: 'View receipt',
              subtitle: 'See your payment details.',
              onTap: () =>
                  showComingSoonPopup(context, feature: 'View receipt'),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ActionRow(
              icon: Icons.support_agent_outlined,
              background: context.palette.tintBlue,
              iconColor: context.palette.accent,
              title: 'Contact support',
              subtitle: 'Message the care team about this appointment.',
              onTap: () => context.go(RoutePaths.messages),
            ),
            const SizedBox(height: AppSpacing.md),
            Material(
              color: AppColors.blue,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                onTap: () => context.goBack(fallback: RoutePaths.visits),
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back, color: AppColors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
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

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.background,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.busy = false,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: busy ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.palette.elevated,
                  shape: BoxShape.circle,
                ),
                child: busy
                    ? Padding(
                        padding: const EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: iconColor,
                        ),
                      )
                    : Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: context.palette.ink,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: context.palette.inkMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: iconColor),
            ],
          ),
        ),
      ),
    );
  }
}
