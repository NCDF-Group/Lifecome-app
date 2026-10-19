import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/buttons/secondary_button.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../booking/domain/models/appointment.dart';
import '../application/waiting_room_controller.dart';
import '../domain/models/consultation_status.dart';
import 'widgets/video_stage.dart';

/// How often the call screen asks the backend whether the appointment is
/// still going.
const _pollEvery = Duration(seconds: 5);

/// Blueprint view 19 — the consultation itself.
///
/// The state shown here is real (who the appointment is with, whether it is
/// connected or has ended, and how long it has been going). The audio and
/// video are not: no calling service is connected to the backend yet, so the
/// screen says so instead of faking a picture and microphone controls.
class ConsultationCallScreen extends ConsumerStatefulWidget {
  const ConsultationCallScreen({super.key, required this.appointment});

  final Appointment appointment;

  @override
  ConsumerState<ConsultationCallScreen> createState() =>
      _ConsultationCallScreenState();
}

class _ConsultationCallScreenState
    extends ConsumerState<ConsultationCallScreen> {
  Timer? _clock;
  Timer? _poll;
  bool _ending = false;

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    _poll = Timer.periodic(_pollEvery, (_) {
      ref.read(consultationProvider(widget.appointment.id).notifier).poll();
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    _poll?.cancel();
    super.dispose();
  }

  String _elapsed(DateTime? startedAt) {
    if (startedAt == null) return '';
    final elapsed = DateTime.now().difference(startedAt);
    final safe = elapsed.isNegative ? Duration.zero : elapsed;
    final minutes = safe.inMinutes.toString().padLeft(2, '0');
    final seconds = (safe.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _end() async {
    final confirmed = await showConfirmPopup(
      context,
      title: 'End your appointment?',
      message: 'This tells your clinician you have finished.',
      confirmLabel: 'End appointment',
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    setState(() => _ending = true);
    try {
      await ref
          .read(consultationProvider(widget.appointment.id).notifier)
          .end();
      if (!mounted) return;
      context.pushReplacement(RoutePaths.careplan, extra: widget.appointment);
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
      if (mounted) setState(() => _ending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointment = widget.appointment;
    final session = ref.watch(consultationProvider(appointment.id)).value;
    final status = session?.status;
    final ended = status == ConsultationStatus.ended;

    final statusText = switch (status) {
      null => 'Connecting…',
      ConsultationStatus.connected =>
        'Connected • ${_elapsed(session?.startedAt)}',
      ConsultationStatus.reconnecting => 'Reconnecting…',
      ConsultationStatus.audioFallback => 'Audio only',
      ConsultationStatus.clinicianJoining => 'Your clinician is joining',
      ConsultationStatus.ended => 'Appointment ended',
      _ => 'Waiting for your clinician',
    };

    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 25),
          children: [
            const AppHeaderBar(
              showBack: true,
              showBell: false,
              backFallback: RoutePaths.visits,
            ),
            const SizedBox(height: 4),
            ScreenTitle(
              title: 'GP consultation',
              subtitle: appointment.serviceName,
            ),
            const SizedBox(height: 18),
            VideoStage(
              name: appointment.providerName,
              title: appointment.providerName,
              message: statusText,
              minHeight: 300,
            ),
            const SizedBox(height: 14),
            const InfoBanner(
              message:
                  "In-app video and audio calling isn't available yet. Keep "
                  'your phone nearby in case your clinician needs to reach '
                  'you.',
            ),
            const SizedBox(height: 18),
            if (ended)
              PrimaryButton(
                label: 'View your care plan',
                onPressed: () => context.pushReplacement(
                  RoutePaths.careplan,
                  extra: appointment,
                ),
              )
            else
              Center(
                child: Column(
                  children: [
                    Semantics(
                      button: true,
                      label: 'End appointment',
                      excludeSemantics: true,
                      child: Material(
                        color: _endRed,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: _ending ? null : _end,
                          child: SizedBox(
                            width: 56,
                            height: 56,
                            child: Center(
                              child: _ending
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.call_end,
                                      color: AppColors.white,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'End appointment',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: context.palette.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            SecondaryButton(
              label: 'Open messages',
              onPressed: () => context.go(RoutePaths.messages),
            ),
          ],
        ),
      ),
    );
  }
}

/// The screen pack's end-call red.
const _endRed = Color(0xFFF53751);
