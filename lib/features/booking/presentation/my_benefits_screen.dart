import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_svg_icons.dart';
import '../../../core/widgets/design/soft_widgets.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../domain/models/appointment.dart';

/// "My benefits": what the connected plan covers. Until eligibility is
/// confirmed it shows the yellow "Verification required" banner and a
/// "Check entitlement" button per service.
class MyBenefitsScreen extends StatelessWidget {
  const MyBenefitsScreen({super.key});

  void _check(BuildContext context) => context.push(
    RoutePaths.bookingChooseService,
    extra: (BookingAccessType.hmo, null),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            const DesignBackButton(),
            const SizedBox(height: 14),
            const PageHeading(
              'My benefits',
              subtitle: 'Review your plan and available services.',
            ),
            const SizedBox(height: 24),
            const _VerificationBanner(),
            const SizedBox(height: 14),
            _BenefitRow(
              glyph: AppSvgGlyph.briefcaseBold,
              color: AppColors.accentLime,
              title: 'Online GP',
              subtitle: 'Video or phone consultation',
              onCheck: () => _check(context),
            ),
            const _Divider(),
            _BenefitRow(
              glyph: AppSvgGlyph.usersBold,
              color: AppColors.accentGreen,
              title: 'In-person Smart GP Clinic',
              subtitle: 'At selected locations.',
              onCheck: () => _check(context),
            ),
            const _Divider(),
            _BenefitRow(
              glyph: AppSvgGlyph.idCardBold,
              color: AppColors.accentCyan,
              title: 'Follow-up care',
              subtitle: 'Subject to your plan and clinical need.',
              onCheck: () => _check(context),
            ),
            const SizedBox(height: 28),
            SoftCard(
              onTap: () => showComingSoonPopup(context, feature: 'Plan limits'),
              radius: 12,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: const Row(
                children: [
                  AppSvgIcon(
                    AppSvgGlyph.documentBold,
                    size: 26,
                    color: AppColors.actionBlue,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Plan limits and exclusions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.3,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  AppSvgIcon(
                    AppSvgGlyph.chevronLine,
                    size: 22,
                    color: AppColors.actionBlue,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const InfoNote(
              'Clinic visits are not automatically included in online GP '
              'benefits. Medicines and tests may cost extra.',
              centerIcon: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _VerificationBanner extends StatelessWidget {
  const _VerificationBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCEA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE346)),
      ),
      child: const Row(
        children: [
          IconCircle(
            glyph: AppSvgGlyph.clockBold,
            color: Color(0xFFE08A00),
            fill: Color(0xFFFFF8C5),
            iconSize: 24,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verification required',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Check your eligibility to view your benefit details.',
                  style: TextStyle(
                    fontSize: 13,
                    letterSpacing: -0.2,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.glyph,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onCheck,
  });

  final AppSvgGlyph glyph;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          SizedBox(width: 34, child: AppSvgIcon(glyph, size: 30, color: color)),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    letterSpacing: -0.2,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          PillButton(
            label: 'Check entitlement',
            outlined: true,
            expand: false,
            height: 44,
            fontSize: 14,
            onPressed: onCheck,
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, thickness: 1, color: AppColors.cardBorder);
}
