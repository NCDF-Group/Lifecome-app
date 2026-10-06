import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../booking/domain/models/appointment.dart';

/// Blueprint view 18 — Consultation Waiting Room. There is no real signaling
/// server, so "Join call" is always available immediately rather than
/// waiting for the doctor to actually connect.
class WaitingRoomScreen extends StatelessWidget {
  const WaitingRoomScreen({super.key, required this.selection});

  final BookingSelection selection;

  @override
  Widget build(BuildContext context) {
    final doctor = selection.doctor!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'You are in the waiting room',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.line),
                borderRadius: BorderRadius.circular(AppRadius.control),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.blue.withValues(alpha: 0.1),
                    child: const Icon(Icons.person, color: AppColors.blue),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        '${selection.service?.title ?? 'Consultation'} · ${selection.time ?? ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.tintGreenSoft,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.videocam_outlined,
                    color: AppColors.greenStrong,
                    size: 40,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Your doctor will join shortly',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Connection check',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            const _CheckRow(
              icon: Icons.videocam_outlined,
              label: 'Camera',
              status: 'Ready',
            ),
            const _CheckRow(
              icon: Icons.mic_outlined,
              label: 'Microphone',
              status: 'Ready',
            ),
            const _CheckRow(
              icon: Icons.wifi,
              label: 'Internet',
              status: 'Connected',
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Choose a quiet, private place for your visit.',
              style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Join call',
              icon: Icons.videocam,
              onPressed: () => context.pushReplacement(
                RoutePaths.consultationCall,
                extra: selection,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: TextButton(
                onPressed: () => context.pop(),
                child: const Text('Leave waiting room'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({
    required this.icon,
    required this.label,
    required this.status,
  });

  final IconData icon;
  final String label;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.blue),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: AppColors.ink),
            ),
          ),
          const Icon(Icons.circle, size: 8, color: AppColors.greenStrong),
          const SizedBox(width: 4),
          Text(
            status,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.greenStrong,
            ),
          ),
        ],
      ),
    );
  }
}
