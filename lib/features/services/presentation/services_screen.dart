import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../booking/domain/models/appointment.dart';
import '../domain/models/wellbeing_service.dart';

/// The Services tab — "Explore our services". GP care (medical, direct-pay
/// by default) and Everyday wellbeing (non-medical) side by side, plus the
/// entry point into the employer/HMO-covered path.
class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const countryName = 'England';

    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const AppHeaderBar(),
            const SizedBox(height: 20),
            Text(
              'Explore our services',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: context.palette.ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Choose the support that is right for you.',
              style: TextStyle(fontSize: 14, color: context.palette.inkMuted),
            ),
            const SizedBox(height: 22),
            _SectionHeading(
              label: 'GP care',
              badge: 'Medical care',
              badgeColor: context.palette.accent,
            ),
            const SizedBox(height: 10),
            _ServiceRow(
              icon: Icons.videocam_outlined,
              iconColor: context.palette.positive,
              background: context.palette.tintBlue,
              iconBackground: context.palette.tintBlueStrong,
              title: 'Online GP',
              subtitle: 'Video or telephone appointments.',
              onTap: () => _openDirectBooking(context),
            ),
            const SizedBox(height: 10),
            _ServiceRow(
              icon: Icons.badge_outlined,
              iconColor: context.palette.accent,
              background: context.palette.tintBlue,
              iconBackground: context.palette.tintBlueStrong,
              title: 'Clinic care',
              subtitle: 'In-person GP care.',
              linkLabel: 'Find a clinic',
              onTap: () => _openDirectBooking(context),
            ),
            const SizedBox(height: 10),
            Text(
              'Follow-up, results review and referral advice where appropriate.',
              style: TextStyle(fontSize: 12, color: context.palette.inkMuted),
            ),
            const SizedBox(height: 10),
            Divider(color: context.palette.line),
            const SizedBox(height: 10),
            Text(
              'GP care for adults physically in $countryName.',
              style: TextStyle(fontSize: 12, color: context.palette.inkMuted),
            ),
            const SizedBox(height: 24),
            _SectionHeading(
              label: 'Everyday wellbeing',
              badge: 'Non-medical support',
              badgeColor: context.palette.positive,
            ),
            const SizedBox(height: 10),
            for (final service in wellbeingServices) ...[
              _ServiceRow(
                icon: service.heroIcon,
                iconColor: context.palette.positive,
                background: context.palette.tintGreen,
                iconBackground: context.palette.tintGreenStrong,
                title: service.title,
                subtitle: service.subtitle,
                onTap: () =>
                    context.push(RoutePaths.wellbeingService, extra: service),
              ),
              const SizedBox(height: 10),
            ],
            _ServiceRow(
              icon: Icons.badge_outlined,
              iconColor: context.palette.accent,
              background: context.palette.tintBlue,
              iconBackground: context.palette.tintBlueStrong,
              title: 'Have employer access?',
              subtitle: 'Check your benefits.',
              onTap: () => context.push(RoutePaths.payerSelectHmo),
            ),
          ],
        ),
      ),
    );
  }

  void _openDirectBooking(BuildContext context) {
    context.push(
      RoutePaths.bookingChooseService,
      extra: (BookingAccessType.direct, null),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.label,
    required this.badge,
    required this.badgeColor,
  });

  final String label;
  final String badge;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w600,
            color: context.palette.ink,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            badge,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({
    required this.icon,
    required this.iconColor,
    required this.background,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.linkLabel,
  });

  final IconData icon;
  final Color iconColor;
  final Color background;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final String? linkLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
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
                    if (linkLabel != null)
                      Text(
                        linkLabel!,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: context.palette.accent,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: iconColor),
            ],
          ),
        ),
      ),
    );
  }
}
