import 'dart:async';

import 'package:daily_flutter/daily_flutter.dart';
import 'package:flutter/material.dart';
import 'package:lifecome_mobile/core/theme/app_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/buttons/secondary_button.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../booking/domain/models/appointment.dart';
import '../../booking/domain/models/consultation_mode.dart';
import '../application/waiting_room_controller.dart';
import '../data/daily_call_repository.dart';
import '../domain/models/consultation_status.dart';
import 'widgets/video_stage.dart';

const _pollEvery = Duration(seconds: 5);

/// The patient joins a private Daily room using a short-lived token from the backend.
class ConsultationCallScreen extends ConsumerStatefulWidget {
  const ConsultationCallScreen({super.key, required this.appointment});

  final Appointment appointment;

  @override
  ConsumerState<ConsultationCallScreen> createState() =>
      _ConsultationCallScreenState();
}

class _ConsultationCallScreenState
    extends ConsumerState<ConsultationCallScreen> {
  final _remoteVideo = VideoViewController();
  final _localVideo = VideoViewController();
  Timer? _clock;
  Timer? _poll;
  StreamSubscription<Event>? _dailyEvents;
  CallClient? _dailyClient;
  bool _joining = false;
  bool _ending = false;
  bool _microphoneEnabled = true;
  bool _cameraEnabled = true;
  bool _hasRemoteParticipant = false;
  bool _hasRemoteVideo = false;
  bool _hasLocalVideo = false;
  String? _callError;

  bool get _videoAppointment =>
      widget.appointment.mode == ConsultationMode.video;

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    _poll = Timer.periodic(_pollEvery, (_) {
      ref.read(consultationProvider(widget.appointment.id).notifier).poll();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_joinDaily());
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    _poll?.cancel();
    unawaited(_leaveDaily());
    _remoteVideo.dispose();
    _localVideo.dispose();
    super.dispose();
  }

  Future<void> _joinDaily() async {
    if (_joining || _dailyClient?.callState == CallState.joined) return;
    setState(() {
      _joining = true;
      _callError = null;
    });

    try {
      final credentials = await ref
          .read(dailyCallRepositoryProvider)
          .joinPatientCall(widget.appointment.id);
      if (!mounted) return;

      final client = await CallClient.create();
      if (!mounted) {
        await client.dispose();
        return;
      }
      _dailyClient = client;
      _dailyEvents = client.events.listen(
        (_) {
          unawaited(_syncVideoTracks(client));
          if (mounted) setState(() {});
        },
        onError: (Object _) {
          unawaited(_leaveDaily());
          if (mounted) {
            setState(
              () => _callError = 'The call connection was interrupted. Check your connection and try again.',
            );
          }
        },
      );

      await client.updateInputs(
        inputs: InputSettingsUpdate.set(
          camera: CameraInputSettingsUpdate.set(
            isEnabled: BoolUpdate.set(_videoAppointment && _cameraEnabled),
          ),
          microphone: MicrophoneInputSettingsUpdate.set(
            isEnabled: BoolUpdate.set(_microphoneEnabled),
          ),
        ),
      );
      await client.join(
        url: Uri.parse(credentials.roomUrl),
        token: credentials.token,
      );
      await _syncVideoTracks(client);
    } on ApiException catch (error) {
      await _leaveDaily();
      if (mounted) setState(() => _callError = error.message);
    } catch (_) {
      await _leaveDaily();
      if (mounted) {
        setState(() {
          _callError = 'Could not join the call. Check your internet connection and camera or microphone permissions, then try again.';
        });
      }
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  Future<void> _syncVideoTracks(CallClient client) async {
    if (!identical(_dailyClient, client)) return;
    final participants = client.participants;
    final remotes = participants.remote.values;
    final remote = remotes.isEmpty ? null : remotes.first;
    final remoteTrack = remote?.media?.camera.track;
    final localTrack = participants.local.media?.camera.track;
    await _remoteVideo.setTrack(remoteTrack);
    await _localVideo.setTrack(localTrack);
    if (mounted && identical(_dailyClient, client)) {
      setState(() {
        _hasRemoteParticipant = remote != null;
        _hasRemoteVideo = remoteTrack != null;
        _hasLocalVideo = localTrack != null;
      });
    }
  }

  Future<void> _leaveDaily() async {
    final subscription = _dailyEvents;
    _dailyEvents = null;
    await subscription?.cancel();
    final client = _dailyClient;
    _dailyClient = null;
    if (client == null) return;
    try {
      await client.leave();
    } catch (_) {
      // The SDK can already be in its left state after a network failure.
    }
    try {
      await client.dispose();
    } catch (_) {
      // The call resources have already been released.
    }
  }

  String _elapsed(DateTime? startedAt) {
    if (startedAt == null) return '';
    final elapsed = DateTime.now().difference(startedAt);
    final safe = elapsed.isNegative ? Duration.zero : elapsed;
    final minutes = safe.inMinutes.toString().padLeft(2, '0');
    final seconds = (safe.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _toggleMicrophone() async {
    final client = _dailyClient;
    if (client == null) return;
    final enabled = !_microphoneEnabled;
    try {
      await client.setInputsEnabled(microphone: enabled);
      if (mounted) setState(() => _microphoneEnabled = enabled);
    } catch (_) {
      if (mounted) {
        setState(() => _callError = 'Could not change microphone settings.');
      }
    }
  }

  Future<void> _toggleCamera() async {
    final client = _dailyClient;
    if (client == null || !_videoAppointment) return;
    final enabled = !_cameraEnabled;
    try {
      await client.setInputsEnabled(camera: enabled);
      if (mounted) setState(() => _cameraEnabled = enabled);
    } catch (_) {
      if (mounted) {
        setState(() => _callError = 'Could not change camera settings.');
      }
    }
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
      await _leaveDaily();
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

  Widget _stage(String statusText) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A3150), Color(0xFF0B2437)],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_hasRemoteVideo)
            VideoView(controller: _remoteVideo)
          else
            Center(
              child: VideoStage(
                name: widget.appointment.providerName,
                title: widget.appointment.providerName,
                message: _hasRemoteParticipant
                    ? 'Your clinician has joined'
                    : statusText,
                minHeight: 250,
              ),
            ),
          if (_hasLocalVideo && _videoAppointment)
            Positioned(
              top: 14,
              right: 14,
              width: 92,
              height: 132,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: VideoView(controller: _localVideo),
              ),
            ),
          Positioned(
            left: 14,
            right: 14,
            bottom: 14,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Text(
                    statusText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _control({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: color,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: SizedBox(
              width: 54,
              height: 54,
              child: Icon(icon, color: AppColors.white, size: 23),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: context.palette.inkMuted),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appointment = widget.appointment;
    final consultation = ref.watch(consultationProvider(appointment.id));
    ref.listen(consultationProvider(appointment.id), (_, next) {
      if (next.value?.status == ConsultationStatus.ended) {
        unawaited(_leaveDaily());
      }
    });
    final session = consultation.value;
    final status = session?.status;
    final ended = status == ConsultationStatus.ended;
    final callJoined = _dailyClient?.callState == CallState.joined;
    final connected = callJoined && _hasRemoteParticipant;
    final statusText = connected
        ? 'Connected • ${_elapsed(session?.startedAt)}'
        : switch (status) {
            null =>
              _joining ? 'Connecting securely…' : 'Waiting for your clinician',
            ConsultationStatus.connected =>
              callJoined
                  ? 'In the call • waiting for your clinician'
                  : 'Connecting…',
            ConsultationStatus.reconnecting => 'Reconnecting…',
            ConsultationStatus.audioFallback => 'Audio only',
            ConsultationStatus.clinicianJoining => 'Your clinician is joining',
            ConsultationStatus.ended => 'Appointment ended',
            _ => 'Waiting for your clinician',
          };

    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppHeaderBar(
                showBack: true,
                showBell: false,
                backFallback: RoutePaths.visits,
              ),
              const SizedBox(height: 4),
              ScreenTitle(
                title: appointment.mode == ConsultationMode.audio
                    ? 'Phone consultation'
                    : 'GP consultation',
                subtitle: appointment.serviceName,
              ),
              const SizedBox(height: 14),
              Expanded(child: _stage(statusText)),
              if (_callError != null) ...[
                const SizedBox(height: 12),
                InfoBanner(message: _callError!),
                const SizedBox(height: 8),
                SecondaryButton(
                  label: _joining ? 'Connecting…' : 'Try again',
                  onPressed: _joining ? null : _joinDaily,
                ),
              ],
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _control(
                      label: _microphoneEnabled ? 'Mute' : 'Unmute',
                      icon: _microphoneEnabled ? AppIcons.mic : AppIcons.micOff,
                      color: _microphoneEnabled
                          ? const Color(0xFF243C54)
                          : const Color(0xFF576879),
                      onPressed: _dailyClient == null
                          ? null
                          : _toggleMicrophone,
                    ),
                    if (_videoAppointment)
                      _control(
                        label: _cameraEnabled ? 'Camera off' : 'Camera on',
                        icon: _cameraEnabled
                            ? AppIcons.video
                            : AppIcons.videoOff,
                        color: _cameraEnabled
                            ? const Color(0xFF243C54)
                            : const Color(0xFF576879),
                        onPressed: _dailyClient == null ? null : _toggleCamera,
                      ),
                    _control(
                      label: _ending ? 'Ending…' : 'End call',
                      icon: AppIcons.phoneOff,
                      color: _endRed,
                      onPressed: _ending ? null : _end,
                    ),
                  ],
                ),
              const SizedBox(height: 14),
              if (!ended)
                SecondaryButton(
                  label: 'Open messages',
                  onPressed: () => context.go(RoutePaths.messages),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

const _endRed = Color(0xFFF53751);
