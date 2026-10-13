import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
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
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            AppHeaderBar(showBack: true, onBack: () => context.pop()),
            const SizedBox(height: 20),
            Text(
              'Your waiting room',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: context.palette.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'You’re checked in. We’ll let you know when your '
              'clinician is ready.',
              style: TextStyle(
                fontSize: 14,
                color: context.palette.inkMuted,
                height: 1.4,
              ),
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
                    child: Icon(Icons.person, color: context.palette.accent),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selection.service?.title ?? 'Online GP',
                        style: TextStyle(
                          fontSize: 13,
                          color: context.palette.inkMuted,
                        ),
                      ),
                      Text(
                        selection.time ?? '',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: context.palette.ink,
                        ),
                      ),
                      Text(
                        doctor.name,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.palette.inkMuted,
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
            Text(
              'Waiting for your clinician',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: context.palette.ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'We’ll connect you as soon as they’re ready.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: context.palette.inkMuted),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.palette.tintGreen,
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
              color: context.palette.tintBlue,
              borderRadius: BorderRadius.circular(AppRadius.control),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.control),
                onTap: () =>
                    showComingSoonPopup(context, feature: 'Update location'),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 20,
                        color: context.palette.accent,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current location',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: context.palette.inkMuted,
                              ),
                            ),
                            Text(
                              'London',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: context.palette.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Confirm or update',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: context.palette.accent,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: context.palette.accent,
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
              color: context.palette.tintBlue,
              borderRadius: BorderRadius.circular(AppRadius.control),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.control),
                onTap: () =>
                    showComingSoonPopup(context, feature: 'Telephone fallback'),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
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
                              'Request telephone fallback',
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
                onPressed: () => context.pop(),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.palette.tintBlue,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.palette.accent, width: 2.5),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.person,
                    size: 56,
                    color: context.palette.accent,
                  ),
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
        Icon(Icons.check_circle, size: 18, color: context.palette.positive),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: TextStyle(fontSize: 14, color: context.palette.ink)),
      ],
    );
  }
}
