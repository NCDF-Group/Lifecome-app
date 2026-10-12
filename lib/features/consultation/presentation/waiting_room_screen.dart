import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../booking/domain/models/appointment.dart';

/// Blueprint view 18 — Consultation Waiting Room. There is no real signaling
/// server, so "Test audio and video" doubles as the way in — it goes
/// straight to the call rather than waiting for the doctor to connect.
class WaitingRoomScreen extends StatelessWidget {
  const WaitingRoomScreen({super.key, required this.selection});

  final BookingSelection selection;

  @override
  Widget build(BuildContext context) {
    final doctor = selection.doctor!;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            AppHeaderBar(showBack: true, onBack: () => context.pop()),
            const SizedBox(height: 20),
            const Text(
              'Your waiting room',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'You’re checked in. We’ll let you know when your '
              'clinician is ready.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.inkMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFFE3EEFB),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.white,
                    child: Icon(Icons.person, color: AppColors.blue),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selection.service?.title ?? 'Online GP',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.inkMuted,
                        ),
                      ),
                      Text(
                        selection.time ?? '',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        doctor.name,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const _WaitingIllustration(),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Waiting for your clinician',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'We’ll connect you as soon as they’re ready.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.inkMuted),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF7E8),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: const Column(
                children: [
                  _CheckRow(label: 'Camera ready'),
                  SizedBox(height: AppSpacing.xs),
                  _CheckRow(label: 'Microphone ready'),
                  SizedBox(height: AppSpacing.xs),
                  _CheckRow(label: 'Connection ready'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Material(
              color: const Color(0xFFE3EEFB),
              borderRadius: BorderRadius.circular(AppRadius.control),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.control),
                onTap: () =>
                    showComingSoonPopup(context, feature: 'Update location'),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 20,
                        color: AppColors.blue,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current location',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: AppColors.inkMuted,
                              ),
                            ),
                            Text(
                              'London',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        'Confirm or update',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.blue,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: AppColors.blue,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: 'Test audio and video',
              icon: Icons.videocam_outlined,
              onPressed: () => context.pushReplacement(
                RoutePaths.consultationCall,
                extra: selection,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Material(
              color: const Color(0xFFE3EEFB),
              borderRadius: BorderRadius.circular(AppRadius.control),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.control),
                onTap: () =>
                    showComingSoonPopup(context, feature: 'Telephone fallback'),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 20,
                        color: AppColors.blue,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Trouble connecting?',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                            Text(
                              'Request telephone fallback',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: AppColors.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.blue),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: TextButton(
                onPressed: () => context.pop(),
                child: const Text(
                  'Leave waiting room',
                  style: TextStyle(
                    color: AppColors.blue,
                    fontWeight: FontWeight.w700,
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

class _WaitingIllustration extends StatelessWidget {
  const _WaitingIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned(
            left: 70,
            top: 10,
            child: Icon(Icons.circle, size: 6, color: AppColors.blue),
          ),
          const Positioned(
            right: 60,
            top: 30,
            child: Icon(Icons.circle, size: 4, color: AppColors.blue),
          ),
          const Positioned(
            left: 50,
            bottom: 20,
            child: Icon(Icons.circle, size: 4, color: AppColors.blue),
          ),
          Container(
            width: 170,
            height: 120,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE3EEFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.blue, width: 2.5),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(Icons.person, size: 56, color: AppColors.blue),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: AppColors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.videocam,
                      size: 12,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
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

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle, size: 18, color: AppColors.greenStrong),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: const TextStyle(fontSize: 14, color: AppColors.ink)),
      ],
    );
  }
}
