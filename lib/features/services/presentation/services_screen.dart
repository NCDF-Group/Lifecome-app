import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/country/app_country.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../booking/domain/models/appointment.dart';
import '../domain/models/wellbeing_service.dart';

/// The Services tab — "Explore our services". GP care (medical, direct-pay
/// by default) and Everyday wellbeing (non-medical) side by side, plus the
/// entry point into the employer/HMO-covered path.
class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final country = ref.watch(countryProvider);
    final countryName = country == AppCountry.nigeria ? 'Nigeria' : 'England';

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const AppHeaderBar(),
            const SizedBox(height: 20),
            const Text(
              'Explore our services',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Choose the support that is right for you.',
              style: TextStyle(fontSize: 14, color: AppColors.inkMuted),
            ),
            const SizedBox(height: 22),
            const _SectionHeading(
              label: 'GP care',
              badge: 'Medical care',
              badgeColor: AppColors.blue,
            ),
            const SizedBox(height: 10),
            _ServiceRow(
              icon: Icons.videocam_outlined,
              iconColor: AppColors.greenStrong,
              background: const Color(0xFFE3EEFB),
              iconBackground: const Color(0xFFDCEEFA),
              title: 'Online GP',
              subtitle: 'Video or telephone appointments.',
              onTap: () => _openDirectBooking(context),
            ),
            const SizedBox(height: 10),
            _ServiceRow(
              icon: Icons.badge_outlined,
              iconColor: AppColors.blue,
              background: const Color(0xFFE3EEFB),
              iconBackground: const Color(0xFFDCEEFA),
              title: 'Clinic care',
              subtitle: 'In-person GP care.',
              linkLabel: 'Find a clinic',
              onTap: () => _openDirectBooking(context),
            ),
            const SizedBox(height: 10),
            const Text(
              'Follow-up, results review and referral advice where appropriate.',
              style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
            ),
            const SizedBox(height: 10),
            const Divider(color: AppColors.line),
            const SizedBox(height: 10),
            Text(
              'GP care for adults physically in $countryName.',
              style: const TextStyle(fontSize: 12, color: AppColors.inkMuted),
            ),
            const SizedBox(height: 24),
            const _SectionHeading(
              label: 'Everyday wellbeing',
              badge: 'Non-medical support',
              badgeColor: AppColors.greenStrong,
            ),
            const SizedBox(height: 10),
            for (final service in wellbeingServices) ...[
              _ServiceRow(
                icon: service.heroIcon,
                iconColor: AppColors.greenStrong,
                background: const Color(0xFFEAF7E8),
                iconBackground: const Color(0xFFD7F0D2),
                title: service.title,
                subtitle: service.subtitle,
                onTap: () =>
                    context.push(RoutePaths.wellbeingService, extra: service),
              ),
              const SizedBox(height: 10),
            ],
            _ServiceRow(
              icon: Icons.badge_outlined,
              iconColor: AppColors.blue,
              background: const Color(0xFFE3EEFB),
              iconBackground: const Color(0xFFDCEEFA),
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
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
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
              fontWeight: FontWeight.w700,
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
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.inkMuted,
                      ),
                    ),
                    if (linkLabel != null)
                      Text(
                        linkLabel!,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.blue,
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
