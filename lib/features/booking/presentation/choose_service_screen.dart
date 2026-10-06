import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/animation/fade_in.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_svg_icons.dart';
import '../../../core/widgets/design/soft_widgets.dart';
import '../../dashboard/presentation/widgets/home_header.dart';
import '../domain/models/appointment.dart';
import '../domain/models/clinical_service.dart';

/// "How can we help?" — pick the kind of care, and whether it's online or in
/// person. One screen serves both the HMO and the direct-pay path (blueprint
/// views 09/10); the choice flows on into Find a GP via [BookingSelection].
class ChooseServiceScreen extends StatefulWidget {
  const ChooseServiceScreen({
    super.key,
    required this.accessType,
    this.hmoName,
  });

  final BookingAccessType accessType;
  final String? hmoName;

  @override
  State<ChooseServiceScreen> createState() => _ChooseServiceScreenState();
}

class _ChooseServiceScreenState extends State<ChooseServiceScreen> {
  bool _online = true;

  ClinicalService _service(String id) =>
      clinicalServices.firstWhere((service) => service.id == id);

  void _choose(String serviceId) {
    final selection = BookingSelection(
      accessType: widget.accessType,
      hmoName: widget.hmoName,
      service: _service(serviceId),
      consultationType: _online ? 'Video consultation' : 'In-person visit',
    );
    context.push(
      _online ? RoutePaths.doctorsFindADoctor : RoutePaths.bookLocations,
      extra: selection,
    );
  }

  @override
  Widget build(BuildContext context) {
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
                'How can we help?',
                subtitle: 'Choose a service to get started.',
              ),
            ),
            const SizedBox(height: 22),
            FadeIn(
              delay: const Duration(milliseconds: 60),
              child: _CardRow(
                left: _ServiceCard(
                  glyph: AppSvgGlyph.stethoscope,
                  color: AppColors.actionBlue,
                  title: 'GP consultation',
                  subtitle: 'Discuss a suitable health concern.',
                  onTap: () => _choose('gp-consultation'),
                ),
                right: _ServiceCard(
                  glyph: AppSvgGlyph.heartPlusBold,
                  color: AppColors.accentLime,
                  title: 'Follow-up care',
                  subtitle: 'Review your progress.',
                  onTap: () => _choose('follow-up'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            FadeIn(
              delay: const Duration(milliseconds: 120),
              child: _CardRow(
                left: _ServiceCard(
                  glyph: AppSvgGlyph.noteBold,
                  color: AppColors.accentGreen,
                  title: 'Results review',
                  subtitle: 'Discuss an existing report',
                  onTap: () => _choose('results-review'),
                ),
                right: _ServiceCard(
                  glyph: AppSvgGlyph.idCardBold,
                  color: AppColors.accentCyan,
                  title: 'Referral advice',
                  subtitle: 'Plan the appropriate next step.',
                  onTap: () => _choose('referral-advice'),
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Preferred care settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            SlidingSegments(
              items: const [
                SegmentItem('Online', glyph: AppSvgGlyph.videoBold),
                SegmentItem('In Person', glyph: AppSvgGlyph.pinBold),
              ],
              selected: _online ? 0 : 1,
              onChanged: (index) => setState(() => _online = index == 0),
            ),
            const SizedBox(height: 32),
            const InfoNote(
              'Your clinician will assess the appropriate care settings.',
            ),
          ],
        ),
      ),
    );
  }
}

class _CardRow extends StatelessWidget {
  const _CardRow({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: left),
          const SizedBox(width: 12),
          Expanded(child: right),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.glyph,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final AppSvgGlyph glyph;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(18, 24, 14, 22),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 150),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSvgIcon(glyph, size: 56, color: color),
            const SizedBox(height: 28),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                height: 1.45,
                letterSpacing: -0.2,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
