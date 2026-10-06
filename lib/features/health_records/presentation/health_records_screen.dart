import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/animation/fade_in.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_svg_icons.dart';
import '../../../core/widgets/design/soft_widgets.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../dashboard/presentation/widgets/home_header.dart';

enum _Status { signed, available, awaitingReview }

class _Record {
  const _Record({
    required this.glyph,
    required this.color,
    required this.fill,
    required this.title,
    required this.date,
    required this.status,
    required this.online,
    this.isCarePlan = false,
  });

  final AppSvgGlyph glyph;
  final Color color;
  final Color fill;
  final String title;
  final String date;
  final _Status status;

  /// Which tab (Online / Clinic) it shows under; everything shows under All.
  final bool online;
  final bool isCarePlan;
}

const _blueFill = Color(0xFFD6E6F5);
const _greenFill = Color(0xFFE2F2D6);

/// Example records only — no records backend exists yet.
const _records = [
  _Record(
    glyph: AppSvgGlyph.stethoscope,
    color: AppColors.actionBlue,
    fill: _blueFill,
    title: 'Online GP consultation',
    date: '25 September 2026',
    status: _Status.signed,
    online: true,
  ),
  _Record(
    glyph: AppSvgGlyph.buildingBold,
    color: AppColors.accentGreen,
    fill: _greenFill,
    title: 'Clinic visit',
    date: '12 September 2026',
    status: _Status.signed,
    online: false,
  ),
  _Record(
    glyph: AppSvgGlyph.documentBold,
    color: AppColors.actionBlue,
    fill: _blueFill,
    title: 'Care plan',
    date: '10 September 2026',
    status: _Status.available,
    online: true,
    isCarePlan: true,
  ),
  _Record(
    glyph: AppSvgGlyph.documentUploadBold,
    color: AppColors.actionBlue,
    fill: _blueFill,
    title: 'Uploaded result',
    date: '08 September 2026',
    status: _Status.awaitingReview,
    online: false,
  ),
];

/// The Records tab (blueprint view 21): the patient's health records,
/// filterable by Online / Clinic. The care plan opens from here.
class HealthRecordsScreen extends StatefulWidget {
  const HealthRecordsScreen({super.key});

  @override
  State<HealthRecordsScreen> createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final visible = [
      for (final record in _records)
        if (_tab == 0 || (_tab == 1) == record.online) record,
    ];

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: [
            const HomeHeader(),
            const SizedBox(height: 28),
            const FadeIn(
              child: PageHeading(
                'Your health records',
                subtitle: 'View and manage your LifeCome records.',
              ),
            ),
            const SizedBox(height: 22),
            SlidingSegments(
              items: const [
                SegmentItem('All'),
                SegmentItem('Online'),
                SegmentItem('Clinic'),
              ],
              selected: _tab,
              onChanged: (index) => setState(() => _tab = index),
              height: 52,
              fontSize: 19,
            ),
            const SizedBox(height: 22),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: Column(
                key: ValueKey(_tab),
                children: [
                  for (final record in visible)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _RecordCard(
                        record: record,
                        onTap: () => record.isCarePlan
                            ? context.go(RoutePaths.careplan)
                            : showComingSoonPopup(
                                context,
                                feature: record.title,
                              ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            PillButton(
              label: 'Upload a document',
              height: 54,
              onPressed: () async {
                final source = await showUploadPhotoPopup(context);
                if (source == null || !context.mounted) return;
                showComingSoonPopup(context, feature: 'Document upload');
              },
            ),
            const SizedBox(height: 26),
            const InfoNote(
              'Your LifeCome records may not include your complete medical '
              'history.',
              centerIcon: true,
            ),
            const SizedBox(height: 18),
            LinkRow(
              glyph: AppSvgGlyph.hexagonBold,
              title: 'Manage sharing permissions',
              onTap: () =>
                  showComingSoonPopup(context, feature: 'Sharing permissions'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record, required this.onTap});

  final _Record record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      fill: AppColors.white,
      radius: 14,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
      child: Row(
        children: [
          IconCircle(
            glyph: record.glyph,
            color: record.color,
            fill: record.fill,
            size: 52,
            iconSize: 26,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        record.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusChip(status: record.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  record.date,
                  style: const TextStyle(
                    fontSize: 15,
                    letterSpacing: -0.3,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const AppSvgIcon(
            AppSvgGlyph.chevronLine,
            size: 22,
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final _Status status;

  @override
  Widget build(BuildContext context) {
    final (label, glyph, fill, color) = switch (status) {
      _Status.signed => (
        'Signed',
        AppSvgGlyph.checkCircleBold,
        const Color(0xFFDDF8E6),
        const Color(0xFF1B9C4A),
      ),
      _Status.available => (
        'Available',
        AppSvgGlyph.documentBold,
        const Color(0xFFE3EEF8),
        AppColors.actionBlue,
      ),
      _Status.awaitingReview => (
        'Awaiting review',
        AppSvgGlyph.clockBold,
        const Color(0xFFFFF3C4),
        const Color(0xFFD9820B),
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSvgIcon(glyph, size: 16, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.2,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
