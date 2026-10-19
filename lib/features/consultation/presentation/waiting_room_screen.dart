import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/router/safe_back.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/feedback/error_state.dart';
import '../../../core/widgets/feedback/loading_indicator.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/buttons/ghost_button.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/lists/row_card.dart';
import '../../../core/widgets/lists/timeline_item.dart';
import '../../../core/widgets/media/lc_icons.dart';
import 'widgets/video_stage.dart';
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
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 25),
          children: [
            const AppHeaderBar(showBack: true, backFallback: RoutePaths.visits),
            const SizedBox(height: 4),
            ScreenTitle(
              title: 'Your GP will see you soon',
              subtitle:
                  '${appointment.providerName} · ${Formatters.time(uk)} '
                  '${Formatters.ukZoneLabel(appointment.startsAt)}',
            ),
            const SizedBox(height: 18),
            session.when(
              loading: () => const LoadingIndicator(),
              error: (error, _) => ErrorState(
                error: error,
                onRetry: () =>
                    ref.invalidate(consultationProvider(appointment.id)),
              ),
              data: (data) => _stateBody(context, data.status),
            ),
            const CheckList(
              items: [
                'Find a quiet, private place',
                'Have your medicines and any questions to hand',
              ],
            ),
            RowCard(
              icon: LcIcons.message,
              title: 'Trouble connecting?',
              subtitle: 'Message the care team',
              onTap: () => context.go(RoutePaths.messages),
            ),
            const SizedBox(height: 4),
            GhostButton(
              label: 'Leave waiting room',
              onPressed: () => context.goBack(fallback: RoutePaths.visits),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stateBody(BuildContext context, ConsultationStatus status) {
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VideoStage(
          name: widget.appointment.providerName,
          title: title,
          message: subtitle,
          minHeight: 280,
        ),
        const SizedBox(height: 16),
        if (status.isBeforeWaiting)
          PrimaryButton(
            label: 'Check in',
            loading: _checkingIn,
            onPressed: _checkIn,
          )
        else if (status.isLive)
          PrimaryButton(
            label: 'Join your appointment',
            onPressed: () => context.pushReplacement(
              RoutePaths.consultationCall,
              extra: widget.appointment,
            ),
          )
        else if (status == ConsultationStatus.ended)
          PrimaryButton(
            label: 'View your care plan',
            onPressed: () => context.pushReplacement(
              RoutePaths.careplan,
              extra: widget.appointment,
            ),
          ),
      ],
    );
  }
}
