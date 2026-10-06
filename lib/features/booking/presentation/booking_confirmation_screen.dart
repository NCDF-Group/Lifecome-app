import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../domain/models/appointment.dart';

/// Blueprint view 17 — Booking Confirmation.
class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({super.key, required this.selection});

  final BookingSelection selection;

  @override
  Widget build(BuildContext context) {
    final doctor = selection.doctor!;
    final reference =
        'LC-${selection.date!.year}${selection.date!.month.toString().padLeft(2, '0')}${selection.date!.day.toString().padLeft(2, '0')}-${1000 + doctor.name.length}';

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Center(
              child: Container(
                width: 84,
                height: 84,
                decoration: const BoxDecoration(
                  color: AppColors.greenStrong,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: AppColors.white,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Center(
              child: Text(
                'Appointment confirmed',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            const Center(
              child: Text(
                'Your appointment has been successfully booked.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.inkMuted),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF7E8),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Booking reference',
                    style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
                  ),
                  Text(
                    reference,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${selection.date!.day}/${selection.date!.month}/${selection.date!.year} · ${selection.time}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.line),
                borderRadius: BorderRadius.circular(AppRadius.card),
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
                        selection.consultationType,
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
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F4FC),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What happens next?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    '1. You will receive a reminder before your appointment.',
                    style: TextStyle(fontSize: 13, color: AppColors.ink),
                  ),
                  Text(
                    '2. Join the consultation from the app at the scheduled time.',
                    style: TextStyle(fontSize: 13, color: AppColors.ink),
                  ),
                  Text(
                    '3. Your consultation notes and care plan will be available in your health record.',
                    style: TextStyle(fontSize: 13, color: AppColors.ink),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Go to home',
              onPressed: () => context.go(RoutePaths.home),
            ),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: TextButton.icon(
                onPressed: () => context.push(
                  RoutePaths.consultationWaitingRoom,
                  extra: selection,
                ),
                icon: const Icon(Icons.videocam_outlined),
                label: const Text('Preview the consultation experience'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
