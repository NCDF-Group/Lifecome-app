import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../booking/domain/models/appointment.dart';

/// Blueprint view 20 — Care Plan & Visit Summary, shown once a consultation
/// ends. Reachable directly from Home too (with no completed visit yet, in
/// which case [selection] is null and this shows an empty state instead).
class CarePlanScreen extends StatelessWidget {
  const CarePlanScreen({super.key, this.selection});

  final BookingSelection? selection;

  @override
  Widget build(BuildContext context) {
    if (selection == null) {
      return Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          title: const Text(
            'My care plan',
            style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    color: AppColors.blue,
                    size: 36,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'No care plan yet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Your care plan appears here once you complete a consultation.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.inkMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final doctor = selection!.doctor!;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'My care plan',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF7E8),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.greenStrong),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your consultation is complete',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          'Your next steps, all in one place.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
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
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        '${selection!.service?.title ?? 'Consultation'} · ${selection!.date != null ? "${selection!.date!.day}/${selection!.date!.month}/${selection!.date!.year}" : ''}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _NextStepTile(
              icon: Icons.description_outlined,
              title: 'Visit summary',
              subtitle: 'Reviewed by your doctor',
              onTap: () => context.go(RoutePaths.healthRecords),
            ),
            _NextStepTile(
              icon: Icons.notes_outlined,
              title: 'Care instructions',
              subtitle: 'View the guidance from your doctor',
              onTap: () => context.go(RoutePaths.healthRecords),
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: 'Message care team',
              icon: Icons.chat_bubble_outline,
              onPressed: () => context.go(RoutePaths.messages),
            ),
            TextButton(
              onPressed: () => context.go(RoutePaths.nextSteps),
              child: const Text('View your next steps'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextStepTile extends StatelessWidget {
  const _NextStepTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.control),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.control),
                ),
                child: Icon(icon, color: AppColors.blue, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.inkMuted),
            ],
          ),
        ),
      ),
    );
  }
}
