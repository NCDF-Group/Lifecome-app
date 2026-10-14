import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/router/safe_back.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/media/avatar.dart';
import '../../booking/domain/models/appointment.dart';
import '../application/waiting_room_controller.dart';
import '../domain/models/consultation_status.dart';

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
    final live = status?.isLive ?? false;

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
      backgroundColor: const Color(0xFF0B1220),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: () =>
                        context.goBack(fallback: RoutePaths.visits),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color: AppColors.white,
                    ),
                  ),
                  const Text(
                    'Your appointment',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      UserAvatar(name: appointment.providerName, radius: 56),
                      const SizedBox(height: 18),
                      Text(
                        appointment.providerName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: live
                                  ? AppColors.greenStrong
                                  : Colors.white38,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            statusText,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 18,
                              color: Colors.white70,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "In-app video and audio calling isn't "
                                'available yet. Keep your phone nearby in '
                                'case your clinician needs to reach you.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              color: const Color(0xFF0B2540),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: ended
                  ? FilledButton.icon(
                      onPressed: () => context.pushReplacement(
                        RoutePaths.careplan,
                        extra: appointment,
                      ),
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('View your care plan'),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(28),
                          onTap: _ending ? null : _end,
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor: AppColors.error,
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
                        const SizedBox(height: 6),
                        const Text(
                          'End appointment',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
