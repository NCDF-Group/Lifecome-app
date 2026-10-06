import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/animation/fade_in.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_svg_icons.dart';
import '../../../core/widgets/design/soft_widgets.dart';
import '../../dashboard/presentation/widgets/home_header.dart';
import '../domain/models/access_option.dart';
import '../domain/models/appointment.dart';

/// The Book tab's landing screen: pick how this booking is funded. Paying per
/// visit goes straight to choosing a service; the other three go through
/// "Connect your access".
class ChooseAccessScreen extends StatelessWidget {
  const ChooseAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                children: [
                  const HomeHeader(),
                  const SizedBox(height: 28),
                  const FadeIn(
                    child: PageHeading(
                      'Choose your access',
                      subtitle: 'Choose one funding route for each booking.',
                    ),
                  ),
                  const SizedBox(height: 22),
                  FadeIn(
                    delay: const Duration(milliseconds: 60),
                    child: _CardRow(
                      left: _AccessCard(
                        glyph: AppSvgGlyph.walletBold,
                        color: AppColors.actionBlue,
                        title: 'Pay per visit',
                        hint: 'No membership required',
                        onTap: () => context.push(
                          RoutePaths.bookingChooseService,
                          extra: (BookingAccessType.direct, null),
                        ),
                      ),
                      right: _optionCard(
                        context,
                        AccessOption.lifecomeBenefits,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeIn(
                    delay: const Duration(milliseconds: 120),
                    child: _CardRow(
                      left: _optionCard(context, AccessOption.workplace),
                      right: _optionCard(context, AccessOption.membership),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: InfoNote(
                'Every patient keeps a private clinical account.',
                centerIcon: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionCard(BuildContext context, AccessOption option) {
    return _AccessCard(
      glyph: option.glyph,
      color: option.color,
      title: option.title,
      hint: option.hint,
      onTap: () => context.push(RoutePaths.bookConnectAccess, extra: option),
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

class _AccessCard extends StatelessWidget {
  const _AccessCard({
    required this.glyph,
    required this.color,
    required this.title,
    required this.hint,
    required this.onTap,
  });

  final AppSvgGlyph glyph;
  final Color color;
  final String title;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      radius: 14,
      padding: const EdgeInsets.fromLTRB(18, 20, 14, 18),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 160),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSvgIcon(glyph, size: 54, color: color),
            const SizedBox(height: 18),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                height: 1.25,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hint,
              style: TextStyle(
                fontSize: 13,
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
