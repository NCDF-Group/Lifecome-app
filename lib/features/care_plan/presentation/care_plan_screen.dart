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

const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

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
        backgroundColor: context.palette.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppHeaderBar(showBack: true, onBack: () => context.pop()),
                const Spacer(),
                Container(
                  width: 84,
                  height: 84,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    color: context.palette.accent,
                    size: 36,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'No care plan yet',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: context.palette.ink,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Your care plan appears here once you complete a consultation.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.palette.inkMuted,
                    height: 1.4,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      );
    }

    final doctor = selection!.doctor!;
    final date = selection!.date;
    final dateLabel = date == null
        ? ''
        : '${date.day} ${_months[date.month - 1]} ${date.year}';

    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            AppHeaderBar(showBack: true, onBack: () => context.pop()),
            const SizedBox(height: 20),
            Text(
              'Your care plan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: context.palette.ink,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.palette.tintGreen,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: context.palette.elevated,
                    child: Icon(
                      Icons.check,
                      color: context.palette.positive,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Consultation complete.',
                          style: TextStyle(
                            fontSize: 15,
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
                        if (dateLabel.isNotEmpty)
                          Text(
                            dateLabel,
                            style: TextStyle(
                              fontSize: 13,
                              color: context.palette.inkMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _NextStepTile(
              icon: Icons.description_outlined,
              iconColor: context.palette.positive,
              background: context.palette.tintGreen,
              title: 'Visit summary',
              subtitle: 'Read your consultation note.',
              onTap: () => context.push(RoutePaths.healthRecords),
            ),
            const SizedBox(height: AppSpacing.sm),
            _NextStepTile(
              icon: Icons.reorder,
              iconColor: context.palette.accent,
              background: context.palette.tintBlue,
              title: 'Agreed actions',
              subtitle: 'View clinician instructions.',
              onTap: () => context.push(RoutePaths.healthRecords),
            ),
            const SizedBox(height: AppSpacing.sm),
            _NextStepTile(
              icon: Icons.calendar_month_outlined,
              iconColor: context.palette.positive,
              background: context.palette.tintGreen,
              title: 'Follow-up',
              subtitle: 'See responsible team and next step.',
              onTap: () => context.go(RoutePaths.messages),
            ),
            const SizedBox(height: AppSpacing.sm),
            _NextStepTile(
              icon: Icons.shield_outlined,
              iconColor: context.palette.accent,
              background: context.palette.tintBlue,
              title: 'Safety advice',
              subtitle: 'Read your personal guidance.',
              onTap: () =>
                  showComingSoonPopup(context, feature: 'Safety advice'),
            ),
            const SizedBox(height: AppSpacing.sm),
            _NextStepTile(
              icon: Icons.description_outlined,
              iconColor: context.palette.positive,
              background: context.palette.tintGreen,
              title: 'Prescriptions and letters',
              subtitle: 'View documents.',
              onTap: () => context.push(RoutePaths.healthRecords),
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: 'Message care team',
              icon: Icons.forum_outlined,
              onPressed: () => context.go(RoutePaths.messages),
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
    required this.iconColor,
    required this.background,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color background;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: context.palette.elevated,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: context.palette.ink,
                      ),
                    ),
                    Text(
                      subtitle,
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
    );
  }
}
