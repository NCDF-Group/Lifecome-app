import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

class _Record {
  const _Record({
    required this.icon,
    required this.title,
    required this.meta,
    required this.status,
    required this.statusColor,
    required this.statusIcon,
  });

  final IconData icon;
  final String title;
  final String meta;
  final String status;
  final Color statusColor;
  final IconData statusIcon;
}

const _records = [
  _Record(
    icon: Icons.description_outlined,
    title: 'GP visit summary',
    meta: '9 Sep 2026 · Dr Amaka Okafor',
    status: 'Reviewed',
    statusColor: AppColors.greenStrong,
    statusIcon: Icons.check,
  ),
  _Record(
    icon: Icons.science_outlined,
    title: 'Laboratory report',
    meta: 'Uploaded 8 Sep 2026',
    status: 'Awaiting clinician review',
    statusColor: AppColors.gold,
    statusIcon: Icons.access_time,
  ),
  _Record(
    icon: Icons.note_add_outlined,
    title: 'Care plan',
    meta: '9 Sep 2026',
    status: 'Available',
    statusColor: AppColors.greenStrong,
    statusIcon: Icons.check,
  ),
];

/// Blueprint view 21 — Health Records. No records backend exists yet, so
/// this shows the same three example records as the design (view 18 in the
/// screenshot set), not live data.
class HealthRecordsScreen extends StatelessWidget {
  const HealthRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'Your health records',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const Text(
              'One record across your LifeCome Live visits.',
              style: TextStyle(fontSize: 14, color: AppColors.inkMuted),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search your records',
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
            for (final record in _records) ...[
              _RecordCard(record: record),
              const SizedBox(height: AppSpacing.sm),
            ],
            const SizedBox(height: AppSpacing.xs),
            const Row(
              children: [
                Icon(Icons.lock_outline, size: 14, color: AppColors.inkMuted),
                SizedBox(width: AppSpacing.xxs),
                Text(
                  'Only authorised people can access your records.',
                  style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record});

  final _Record record;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.control),
            ),
            child: Icon(record.icon, color: AppColors.blue, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  record.meta,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.inkMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Row(
                  children: [
                    Icon(
                      record.statusIcon,
                      size: 14,
                      color: record.statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      record.status,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: record.statusColor,
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
    );
  }
}
