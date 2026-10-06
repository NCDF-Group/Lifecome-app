import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../booking/domain/models/appointment.dart';

/// Blueprint view 19 — Video / Audio Consultation. UI only: there is no
/// WebRTC/media-server integration behind this yet (blueprint §10), so the
/// "call" is a static screen with a running timer, not a real connection.
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
    context.go(RoutePaths.careplan, extra: widget.selection);
  }

  @override
  Widget build(BuildContext context) {
    final doctor = widget.selection.doctor!;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF13233B), Color(0xFF0B1220)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.white,
                            ),
                          ),
                          Text(
                            doctor.specialty,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.lime,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formattedElapsed,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Center(
                      child: _cameraOff
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.videocam_off_rounded,
                                  color: Colors.white38,
                                  size: 56,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Your camera is off',
                                  style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            )
                          : Container(
                              width: 148,
                              height: 148,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.blue,
                                    AppColors.greenStrong,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.blue.withValues(
                                      alpha: 0.35,
                                    ),
                                    blurRadius: 40,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                color: AppColors.white,
                                size: 76,
                              ),
                            ),
                    ),
                    Positioned(
                      left: 16,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.wifi_rounded,
                              size: 14,
                              color: AppColors.lime,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Connection good',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 92,
                          height: 124,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.18),
                            ),
                          ),
                          child: Stack(
                            children: [
                              const Center(
                                child: Icon(
                                  Icons.person_rounded,
                                  color: Colors.white38,
                                  size: 36,
                                ),
                              ),
                              Positioned(
                                left: 6,
                                bottom: 6,
                                child: Text(
                                  'You',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _CallButton(
                            icon: _muted
                                ? Icons.mic_off_rounded
                                : Icons.mic_rounded,
                            label: 'Mute',
                            active: _muted,
                            onTap: () => setState(() => _muted = !_muted),
                          ),
                          _CallButton(
                            icon: _cameraOff
                                ? Icons.videocam_off_rounded
                                : Icons.videocam_rounded,
                            label: 'Camera',
                            active: _cameraOff,
                            onTap: () =>
                                setState(() => _cameraOff = !_cameraOff),
                          ),
                          _CallButton(
                            icon: Icons.chat_bubble_rounded,
                            label: 'Chat',
                            onTap: () {},
                          ),
                          _CallButton(
                            icon: Icons.call_end_rounded,
                            label: 'End',
                            color: AppColors.error,
                            onTap: _endCall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
        : const Color(0xFF0B1220);

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
