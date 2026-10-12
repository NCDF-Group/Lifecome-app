import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/animation/fade_in.dart';
import '../../../core/country/app_country.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/max_content_width.dart';

/// Copy that differs between the UK and Nigeria markets. [AppHeaderBar]
/// already shows the selected [AppCountry] as a chip; this is the rest of
/// the welcome screen reacting to that same selection.
class _WelcomeCopy {
  const _WelcomeCopy({
    required this.headlineTail,
    required this.subtitle,
    required this.features,
    required this.eligibility,
    required this.audience,
  });

  final String headlineTail;
  final String subtitle;
  final List<_FeatureIcon> features;
  final String eligibility;
  final String audience;

  static const unitedKingdom = _WelcomeCopy(
    headlineTail: 'connected.',
    subtitle:
        'GP appointments and practical support for healthier routines, '
        'eating well and relaxation.',
    features: [
      _FeatureIcon(
        icon: Icons.videocam_outlined,
        background: Color(0xFFE3EEFB),
        color: AppColors.blue,
        label: 'Online GP',
      ),
      _FeatureIcon(
        icon: Icons.location_on_outlined,
        background: Color(0xFFE6F6E2),
        color: AppColors.greenStrong,
        label: 'Clinic care',
      ),
      _FeatureIcon(
        icon: Icons.spa_outlined,
        background: Color(0xFFE3EEFB),
        color: AppColors.blue,
        label: 'Wellbeing',
      ),
    ],
    eligibility: 'For adults aged 18 and over. GP care in England.',
    audience: 'For members and non-members',
  );

  static const nigeria = _WelcomeCopy(
    headlineTail: 'closer to home.',
    subtitle:
        'GP appointments and practical support for healthier routines, '
        'eating well and relaxation — with or without an HMO.',
    features: [
      _FeatureIcon(
        icon: Icons.videocam_outlined,
        background: Color(0xFFE3EEFB),
        color: AppColors.blue,
        label: 'Online GP',
      ),
      _FeatureIcon(
        icon: Icons.verified_user_outlined,
        background: Color(0xFFE6F6E2),
        color: AppColors.greenStrong,
        label: 'HMO cover',
      ),
      _FeatureIcon(
        icon: Icons.spa_outlined,
        background: Color(0xFFE3EEFB),
        color: AppColors.blue,
        label: 'Wellbeing',
      ),
    ],
    eligibility: 'For adults aged 18 and over. GP care in Nigeria.',
    audience: 'For HMO members and one-time visits',
  );

  static _WelcomeCopy forCountry(AppCountry country) =>
      country == AppCountry.nigeria ? nigeria : unitedKingdom;
}

/// The welcome screen shown after the splash screen when there is no
/// remembered session — the app's front door. Its copy follows the
/// selected [AppCountry] (the same chip shown in [AppHeaderBar]).
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = _WelcomeCopy.forCountry(ref.watch(countryProvider));

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: MaxContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppHeaderBar(),
                const SizedBox(height: 20),
                const FadeIn(child: _HeroPhotos()),
                const SizedBox(height: 24),
                FadeIn(
                  delay: const Duration(milliseconds: 60),
                  child: Text.rich(
                    TextSpan(
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: -0.6,
                        color: AppColors.ink,
                      ),
                      children: [
                        const TextSpan(text: 'GP care and\n'),
                        const TextSpan(
                          text: 'everyday wellbeing,\n',
                          style: TextStyle(color: AppColors.greenStrong),
                        ),
                        TextSpan(text: copy.headlineTail),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FadeIn(
                  delay: const Duration(milliseconds: 100),
                  child: Text(
                    copy.subtitle,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.inkMuted,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FadeIn(
                  delay: const Duration(milliseconds: 140),
                  child: Row(
                    children: [
                      for (var i = 0; i < copy.features.length; i++) ...[
                        if (i != 0) const SizedBox(width: 12),
                        Expanded(child: copy.features[i]),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                FadeIn(
                  delay: const Duration(milliseconds: 180),
                  child: PrimaryButton(
                    label: 'Create an account',
                    icon: Icons.arrow_forward,
                    onPressed: () => context.go(RoutePaths.createAccount),
                  ),
                ),
                const SizedBox(height: 10),
                FadeIn(
                  delay: const Duration(milliseconds: 220),
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => context.go(RoutePaths.signIn),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.ink,
                        side: const BorderSide(
                          color: AppColors.line,
                          width: 1.5,
                        ),
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: const Text('Log in'),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FadeIn(
                  delay: const Duration(milliseconds: 260),
                  child: Column(
                    children: [
                      Text(
                        copy.eligibility,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.inkMuted,
                        ),
                      ),
                      Text(
                        copy.audience,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.inkMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Terms of use  |  Privacy notice',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroPhotos extends StatelessWidget {
  const _HeroPhotos();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            width: 200,
            height: 180,
            child: _PhotoCard(
              asset: 'assets/images/home/doctor.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            width: 190,
            height: 170,
            child: _PhotoCard(
              asset: 'assets/images/welcome/welcome-hero.webp',
              fit: BoxFit.cover,
            ),
          ),
          const Positioned(right: 90, top: 70, child: _PlusBadge()),
        ],
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({required this.asset, required this.fit});

  final String asset;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        children: [
          Positioned.fill(child: Container(color: const Color(0xFFE8F4FC))),
          Positioned.fill(child: Image.asset(asset, fit: fit)),
          const Positioned(left: 10, top: 10, child: _VideoBadge()),
        ],
      ),
    );
  }
}

class _VideoBadge extends StatelessWidget {
  const _VideoBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: const BoxDecoration(
        color: AppColors.blue,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.videocam, color: AppColors.white, size: 16),
    );
  }
}

class _PlusBadge extends StatelessWidget {
  const _PlusBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.greenStrong,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.white, width: 3),
      ),
      child: const Icon(Icons.add, color: AppColors.white, size: 20),
    );
  }
}

class _FeatureIcon extends StatelessWidget {
  const _FeatureIcon({
    required this.icon,
    required this.background,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color background;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(color: background, shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}
