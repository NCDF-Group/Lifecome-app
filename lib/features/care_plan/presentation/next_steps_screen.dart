import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_svg_icons.dart';
import '../../../core/widgets/design/soft_widgets.dart';
import '../../../core/widgets/feedback/app_popup.dart';

/// "Your next steps": what the clinician recommended after a visit — here an
/// in-person assessment. No clinical-notes backend exists yet, so the three
/// summary cards and their wording are fixed.
class NextStepsScreen extends StatelessWidget {
  const NextStepsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            const DesignBackButton(),
            const SizedBox(height: 14),
            const PageHeading(
              'Your next steps',
              subtitle: 'Your clinician recommends an in-person assessment.',
            ),
            const SizedBox(height: 22),
            const _StepCard(
              glyph: AppSvgGlyph.calendarBold,
              color: AppColors.actionBlue,
              title: 'Reason for follow-up',
              subtitle: 'To assess your symptoms and next steps.',
            ),
            const SizedBox(height: 12),
            const _StepCard(
              glyph: AppSvgGlyph.teamBold,
              color: AppColors.accentGreen,
              title: 'Responsible care team',
              subtitle: 'Your care team will be arranging this appointment.',
            ),
            const SizedBox(height: 12),
            const _StepCard(
              glyph: AppSvgGlyph.clockBold,
              color: AppColors.accentLime,
              title: 'Timing set by clinician',
              subtitle: 'We will confirm a suitable date with you.',
              glyphSize: 52,
            ),
            const SizedBox(height: 26),
            PillButton(
              label: 'Review clinic options',
              onPressed: () => context.go(RoutePaths.book),
            ),
            const SizedBox(height: 10),
            PillButton(
              label: 'View consultation summary',
              outlined: true,
              onPressed: () => context.go(RoutePaths.careplan),
            ),
            const SizedBox(height: 26),
            const InfoNote(
              'Clinic availability and any additional fee will be confirmed '
              'before booking.',
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.glyph,
    required this.color,
    required this.title,
    required this.subtitle,
    this.glyphSize = 44,
  });

  final AppSvgGlyph glyph;
  final Color color;
  final String title;
  final String subtitle;
  final double glyphSize;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: () => showComingSoonPopup(context, feature: title),
      radius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 52,
            child: Align(
              alignment: Alignment.topLeft,
              child: AppSvgIcon(glyph, size: glyphSize, color: color),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    letterSpacing: -0.2,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 2),
            child: AppSvgIcon(
              AppSvgGlyph.chevronLine,
              size: 22,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
