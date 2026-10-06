import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../booking/domain/models/appointment.dart';
import '../domain/models/doctor.dart';

/// Blueprint view 11 — Find a Doctor. No provider-directory backend exists
/// yet, so this searches/filters the static `sampleDoctors` list only.
class FindADoctorScreen extends StatefulWidget {
  const FindADoctorScreen({super.key, required this.selection});

  final BookingSelection selection;

  @override
  State<FindADoctorScreen> createState() => _FindADoctorScreenState();
}

class _FindADoctorScreenState extends State<FindADoctorScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final results = sampleDoctors.where((doctor) {
      final query = _query.toLowerCase();
      return query.isEmpty ||
          doctor.name.toLowerCase().contains(query) ||
          doctor.specialty.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'Find a doctor',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(
              widget.selection.service?.title ??
                  'General practitioners available now',
              style: const TextStyle(fontSize: 14, color: AppColors.inkMuted),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Search by name or specialty',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final doctor in results) ...[
              _DoctorCard(
                doctor: doctor,
                onTap: () => context.push(
                  RoutePaths.doctorsProfile,
                  extra: widget.selection.copyWith(doctor: doctor),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ),
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({required this.doctor, required this.onTap});

  final Doctor doctor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.blue.withValues(alpha: 0.1),
                child: const Icon(
                  Icons.person,
                  color: AppColors.blue,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      doctor.specialty,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.star, color: AppColors.gold, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          '${doctor.rating} (${doctor.reviewCount})',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
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
