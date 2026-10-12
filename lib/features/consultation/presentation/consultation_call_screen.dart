import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../booking/domain/models/appointment.dart';

/// Blueprint view 19 — Video / Audio Consultation. UI only: there is no
/// WebRTC/media-server integration behind this yet (blueprint §10), so the
/// "call" is a static screen with a running timer, not a real connection,
/// and the video feed is a colour placeholder rather than a real camera
/// image (no participant photo asset exists for this).
class ConsultationCallScreen extends StatefulWidget {
  const ConsultationCallScreen({super.key, required this.selection});

  final BookingSelection selection;

  @override
  State<ConsultationCallScreen> createState() => _ConsultationCallScreenState();
}

class _ConsultationCallScreenState extends State<ConsultationCallScreen> {
  Duration _elapsed = Duration.zero;
  Timer? _timer;
  bool _muted = false;
  bool _cameraOff = false;
  bool _speakerOn = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedElapsed {
    final minutes = _elapsed.inMinutes.toString().padLeft(2, '0');
    final seconds = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _endCall() {
    context.pushReplacement(RoutePaths.careplan, extra: widget.selection);
  }

  @override
  Widget build(BuildContext context) {
    final doctor = widget.selection.doctor!;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => context.pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SvgPicture.asset(
                    'assets/images/logo/lifecome-live-logo.svg',
                    height: 24,
                    semanticsLabel: 'LifeCome Live',
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _cameraOff
                      ? const ColoredBox(
                          color: Color(0xFF0B1220),
                          child: Center(
                            child: Icon(
                              Icons.videocam_off_rounded,
                              color: Colors.white38,
                              size: 56,
                            ),
                          ),
                        )
                      : Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF3B4958), Color(0xFF1F2A36)],
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.person_rounded,
                              color: Colors.white24,
                              size: 120,
                            ),
                          ),
                        ),
                  Positioned(
                    left: 16,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.white,
                            ),
                          ),
                          Text(
                            doctor.specialty,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: AppColors.greenStrong,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Connected • $_formattedElapsed',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    top: 12,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 86,
                        height: 110,
                        color: const Color(0xFFE0E0E0),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Colors.white70,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.videocam_outlined,
                            size: 14,
                            color: Colors.white70,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Recording off',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: const Color(0xFF0B2540),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CallButton(
                    icon: _muted ? Icons.mic_off : Icons.mic_none,
                    label: 'Mute',
                    active: _muted,
                    onTap: () => setState(() => _muted = !_muted),
                  ),
                  _CallButton(
                    icon: Icons.videocam_outlined,
                    label: 'Camera',
                    active: _cameraOff,
                    onTap: () => setState(() => _cameraOff = !_cameraOff),
                  ),
                  _CallButton(
                    icon: Icons.volume_up_outlined,
                    label: 'Speaker',
                    active: _speakerOn,
                    onTap: () => setState(() => _speakerOn = !_speakerOn),
                  ),
                  _CallButton(
                    icon: Icons.call_end,
                    label: 'End call',
                    color: AppColors.error,
                    onTap: _endCall,
                  ),
                ],
              ),
            ),
            Container(
              color: const Color(0xFF0B2540),
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () => showComingSoonPopup(
                          context,
                          feature: 'Connection help',
                        ),
                        icon: const Icon(
                          Icons.help_outline,
                          size: 16,
                          color: Color(0xFF6EA8E8),
                        ),
                        label: const Text(
                          'Connection help',
                          style: TextStyle(color: Color(0xFF6EA8E8)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => showComingSoonPopup(
                          context,
                          feature: 'Switch to audio',
                        ),
                        icon: const Icon(
                          Icons.phone_outlined,
                          size: 16,
                          color: Color(0xFF6EA8E8),
                        ),
                        label: const Text(
                          'Switch to audio',
                          style: TextStyle(color: Color(0xFF6EA8E8)),
                        ),
                      ),
                    ],
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

class _CallButton extends StatelessWidget {
  const _CallButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final background =
        color ??
        (active ? AppColors.white : Colors.white.withValues(alpha: 0.14));
    final iconColor = color != null || !active
        ? AppColors.white
        : const Color(0xFF0B2540);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: CircleAvatar(
            radius: 26,
            backgroundColor: background,
            child: Icon(icon, color: iconColor),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
