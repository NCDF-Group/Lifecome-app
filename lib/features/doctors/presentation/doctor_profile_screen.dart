import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../booking/domain/models/appointment.dart';

/// Blueprint view 12 — Doctor Profile.
class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key, required this.selection});

  final BookingSelection selection;

  @override
  Widget build(BuildContext context) {
    final doctor = selection.doctor!;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'Doctor profile',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.blue.withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.person,
                        color: AppColors.blue,
                        size: 44,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Center(
                    child: Text(
                      doctor.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      doctor.specialty,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      doctor.credentials,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: AppColors.gold, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${doctor.rating} (${doctor.reviewCount} reviews)',
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
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: AppSpacing.xs,
                    children: const [
                      _Badge(label: 'HMO Verified'),
                      _Badge(label: 'Licensed'),
                      _Badge(label: 'Background Checked'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    'About',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    doctor.about,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.inkMuted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Consultation options',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const _OptionRow(
                    icon: Icons.videocam_outlined,
                    label: 'Video consultation',
                  ),
                  const _OptionRow(
                    icon: Icons.call_outlined,
                    label: 'Audio consultation',
                  ),
                  const _OptionRow(
                    icon: Icons.chat_bubble_outline,
                    label: 'Chat follow-up',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Languages',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    doctor.languages.join(', '),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F4FC),
                      borderRadius: BorderRadius.circular(AppRadius.card),
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.calendar_today_outlined,
                          color: AppColors.blue,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Next available',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.inkMuted,
                                ),
                              ),
                              Text(
                                'Today · 10:00 AM',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: PrimaryButton(
                label: 'Choose appointment time',
                icon: Icons.arrow_forward,
                onPressed: () => context.push(
                  RoutePaths.bookingAppointmentTime,
                  extra: selection,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7E8),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle,
            color: AppColors.greenStrong,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.greenStrong,
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.blue),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}
