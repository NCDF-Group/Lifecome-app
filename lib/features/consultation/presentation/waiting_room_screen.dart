import 'dart:async';

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
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/feedback/error_state.dart';
import '../../../core/widgets/feedback/loading_indicator.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/media/avatar.dart';
import '../../booking/domain/models/appointment.dart';
import '../application/waiting_room_controller.dart';
import '../domain/models/consultation_status.dart';

/// How often the waiting room asks the backend whether the clinician has
/// started the appointment.
const _pollEvery = Duration(seconds: 5);

/// Blueprint view 18 — Consultation Waiting Room. Shows the consultation's
/// real state from the backend: check in, wait, then join once the clinician
/// has started.
class WaitingRoomScreen extends ConsumerStatefulWidget {
  const WaitingRoomScreen({super.key, required this.appointment});

  final Appointment appointment;

  @override
  ConsumerState<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends ConsumerState<WaitingRoomScreen> {
  Timer? _timer;
  bool _checkingIn = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_pollEvery, (_) {
      ref.read(consultationProvider(widget.appointment.id).notifier).poll();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkIn() async {
    setState(() => _checkingIn = true);
    try {
      await ref
          .read(consultationProvider(widget.appointment.id).notifier)
          .checkIn();
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
      if (mounted) setState(() => _checkingIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointment = widget.appointment;
    final session = ref.watch(consultationProvider(appointment.id));
    final uk = Formatters.ukTime(appointment.startsAt);

    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const AppHeaderBar(showBack: true, backFallback: RoutePaths.visits),
            const SizedBox(height: 20),
            const ScreenTitle(title: 'Your waiting room'),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.palette.tintBlue,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Row(
                children: [
                  UserAvatar(name: appointment.providerName, radius: 22),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.serviceName,
                          style: TextStyle(
                            fontSize: 13,
                            color: context.palette.inkMuted,
                          ),
                        ),
                        Text(
                          '${Formatters.time(uk)} '
                          '${Formatters.ukZoneLabel(appointment.startsAt)}',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: context.palette.ink,
                          ),
                        ),
                        Text(
                          appointment.providerName,
                          style: TextStyle(
                            fontSize: 13,
                            color: context.palette.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            session.when(
              loading: () => const LoadingIndicator(),
              error: (error, _) => ErrorState(
                error: error,
                onRetry: () =>
                    ref.invalidate(consultationProvider(appointment.id)),
              ),
              data: (data) => _stateBody(context, data.status),
            ),
            const SizedBox(height: AppSpacing.md),
            Material(
              color: context.palette.tintBlue,
              borderRadius: BorderRadius.circular(AppRadius.control),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.control),
                onTap: () => context.go(RoutePaths.messages),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Row(
                    children: [
                      Icon(
                        Icons.support_agent_outlined,
                        size: 20,
                        color: context.palette.accent,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Trouble connecting?',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: context.palette.ink,
                              ),
                            ),
                            Text(
                              'Message the care team',
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
            const SizedBox(height: AppSpacing.md),
            Center(
              child: TextButton(
                onPressed: () => context.goBack(fallback: RoutePaths.visits),
                child: Text(
                  'Leave waiting room',
                  style: TextStyle(
                    color: context.palette.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stateBody(BuildContext context, ConsultationStatus status) {
    final palette = context.palette;

    final (title, subtitle) = switch (status) {
      ConsultationStatus.booked ||
      ConsultationStatus.checkInOpen ||
      ConsultationStatus.deviceCheck => (
        'Ready to check in?',
        'Let your clinician know you are here.',
      ),
      ConsultationStatus.waiting => (
        'Waiting for your clinician',
        "Keep this screen open. We'll show you here as soon as they are ready.",
      ),
      ConsultationStatus.clinicianJoining => (
        'Your clinician is joining',
        'They are about to start your appointment.',
      ),
      ConsultationStatus.connected => (
        'Your appointment has started',
        'Your clinician is ready for you.',
      ),
      ConsultationStatus.reconnecting => (
        'Reconnecting',
        'Hold on while the connection is restored.',
      ),
      ConsultationStatus.audioFallback => (
        'Continuing by audio',
        'Your appointment is carrying on over audio.',
      ),
      ConsultationStatus.ended => (
        'Your appointment has ended',
        'Your care plan will appear once your clinician has written it up.',
      ),
    };

    return Column(
      children: [
        _WaitingIllustration(ended: status == ConsultationStatus.ended),
        const SizedBox(height: AppSpacing.md),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: palette.ink,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: palette.inkMuted, height: 1.4),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (status.isBeforeWaiting)
          PrimaryButton(
            label: 'Check in',
            icon: Icons.login,
            loading: _checkingIn,
            onPressed: _checkIn,
          )
        else if (status.isLive)
          PrimaryButton(
            label: 'Join your appointment',
            icon: Icons.videocam_outlined,
            onPressed: () => context.pushReplacement(
              RoutePaths.consultationCall,
              extra: widget.appointment,
            ),
          )
        else if (status == ConsultationStatus.ended)
          PrimaryButton(
            label: 'View your care plan',
            icon: Icons.arrow_forward,
            onPressed: () => context.pushReplacement(
              RoutePaths.careplan,
              extra: widget.appointment,
            ),
          ),
      ],
    );
  }
}

class _WaitingIllustration extends StatelessWidget {
  const _WaitingIllustration({required this.ended});

  final bool ended;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 70,
            top: 10,
            child: Icon(Icons.circle, size: 6, color: context.palette.accent),
          ),
          Positioned(
            right: 60,
            top: 30,
            child: Icon(Icons.circle, size: 4, color: context.palette.accent),
          ),
          Positioned(
            left: 50,
            bottom: 20,
            child: Icon(Icons.circle, size: 4, color: context.palette.accent),
          ),
          Container(
            width: 170,
            height: 120,
            decoration: BoxDecoration(
              color: context.palette.tintBlue,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.palette.accent, width: 2.5),
            ),
            child: Center(
              child: Icon(
                ended ? Icons.check_circle_outline : Icons.hourglass_empty,
                size: 52,
                color: context.palette.accent,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: 190,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.blue,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
