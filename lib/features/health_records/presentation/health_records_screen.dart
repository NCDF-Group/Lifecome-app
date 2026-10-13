import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/layout/app_header_bar.dart';

enum _RecordFilter { all, visits, results, carePlans }

class _Record {
  const _Record({
    required this.icon,
    required this.iconColor,
    required this.background,
    required this.title,
    required this.date,
    required this.meta,
    required this.status,
    required this.statusColor,
    required this.statusBackground,
    required this.filter,
  });

  final IconData icon;
  final Color iconColor;
  final Color background;
  final String title;
  final String date;
  final String meta;
  final String status;
  final Color statusColor;
  final Color statusBackground;
  final _RecordFilter filter;
}

const _records = [
  _Record(
    icon: Icons.calendar_month_outlined,
    iconColor: AppColors.greenStrong,
    background: Color(0xFFEAF7E8),
    title: 'GP visit summary',
    date: '12 Oct 2026',
    meta: 'Routine review with GP.',
    status: 'Available',
    statusColor: AppColors.greenStrong,
    statusBackground: Color(0xFFEAF7E8),
    filter: _RecordFilter.visits,
  ),
  _Record(
    icon: Icons.description_outlined,
    iconColor: AppColors.blue,
    background: Color(0xFFE3EEFB),
    title: 'Uploaded report',
    date: '8 Oct 2026',
    meta: 'Blood test results (PDF).',
    status: 'Awaiting clinician review',
    statusColor: Color(0xFFB2690A),
    statusBackground: Color(0xFFFBEBD4),
    filter: _RecordFilter.results,
  ),
  _Record(
    icon: Icons.description_outlined,
    iconColor: AppColors.greenStrong,
    background: Color(0xFFEAF7E8),
    title: 'Care plan',
    date: '1 Sep 2026',
    meta: 'Long-term condition plan.',
    status: 'Available',
    statusColor: AppColors.greenStrong,
    statusBackground: Color(0xFFEAF7E8),
    filter: _RecordFilter.carePlans,
  ),
];

/// Blueprint view 21 — Health Records. No records backend exists yet, so
/// this shows the same three sample records as the design, not live data.
class HealthRecordsScreen extends StatefulWidget {
  const HealthRecordsScreen({super.key});

  @override
  State<HealthRecordsScreen> createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen> {
  _RecordFilter _filter = _RecordFilter.all;

  @override
  Widget build(BuildContext context) {
    final records = _filter == _RecordFilter.all
        ? _records
        : _records.where((r) => r.filter == _filter).toList();

    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const AppHeaderBar(),
            const SizedBox(height: 20),
            Text(
              'Your health records',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: context.palette.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'View your records and care plans, and upload documents '
              'to share with your care team.',
              style: TextStyle(
                fontSize: 14,
                color: context.palette.inkMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search records (e.g. blood test, GP visit)',
                prefixIcon: Icon(Icons.search, color: context.palette.inkMuted),
                filled: true,
                fillColor: context.palette.elevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  borderSide: BorderSide(color: context.palette.line),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  borderSide: BorderSide(color: context.palette.line),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                for (final filter in _RecordFilter.values) ...[
                  _FilterChip(
                    label: switch (filter) {
                      _RecordFilter.all => 'All',
                      _RecordFilter.visits => 'Visits',
                      _RecordFilter.results => 'Results',
                      _RecordFilter.carePlans => 'Care plans',
                    },
                    selected: _filter == filter,
                    onTap: () => setState(() => _filter = filter),
                  ),
                  if (filter != _RecordFilter.values.last)
                    const SizedBox(width: 8),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Sample records',
              style: TextStyle(fontSize: 13, color: context.palette.inkMuted),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final record in records) ...[
              _RecordCard(record: record),
              const SizedBox(height: AppSpacing.sm),
            ],
            Material(
              color: AppColors.blue,
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.card),
                onTap: () =>
                    showComingSoonPopup(context, feature: 'Document upload'),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: context.palette.elevated.withValues(
                            alpha: 0.18,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.cloud_upload_outlined,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Upload a document',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
                            ),
                            Text(
                              'Share test results, letters or other '
                              'documents with your care team.',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: AppColors.white,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.white),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Material(
              color: context.palette.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.card),
                onTap: () => showComingSoonPopup(
                  context,
                  feature: 'Sharing permissions',
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: context.palette.tintBlue,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.people_outline,
                          color: context.palette.accent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Manage sharing permissions',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: context.palette.ink,
                              ),
                            ),
                            Text(
                              'Choose who can view your records.',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: context.palette.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: context.palette.inkMuted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: context.palette.surface,
                borderRadius: BorderRadius.circular(AppRadius.control),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: context.palette.accent,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'These records may not include your complete NHS '
                      'history.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: context.palette.inkMuted,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.blue : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: selected ? AppColors.white : context.palette.inkMuted,
            ),
          ),
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
    return Material(
      color: context.palette.adapt(record.background),
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: () => showComingSoonPopup(context, feature: record.title),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.palette.elevated,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  record.icon,
                  color: context.palette.adapt(record.iconColor),
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: context.palette.ink,
                      ),
                    ),
                    Text(
                      record.date,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: context.palette.inkMuted,
                      ),
                    ),
                    Text(
                      record.meta,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: context.palette.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: context.palette.adapt(record.statusBackground),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      record.status,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: context.palette.adapt(record.statusColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: context.palette.inkMuted,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
