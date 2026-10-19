import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/animation/fade_in.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/country/app_country.dart';
import '../../../core/widgets/layout/max_content_width.dart';

/// The brand blue and green this screen was approved with, from before the
/// screen-pack redesign retuned [AppColors]. See [WelcomeScreen].
const _welcomeBlue = Color(0xFF0667B8);
const _welcomeGreen = Color(0xFF2F7D00);

/// The welcome screen shown after the splash screen when there is no
/// remembered session — the app's front door.
///
/// This screen keeps its approved look through the screen-pack redesign: it
/// reads [AppPalette.welcomeLight] (the pre-redesign light palette) and draws
/// its own header and buttons rather than the restyled shared ones.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (theme.brightness == Brightness.dark) return const _WelcomeBody();
    return Theme(
      data: theme.copyWith(extensions: [AppPalette.welcomeLight]),
      child: const _WelcomeBody(),
    );
  }
}

class _WelcomeBody extends StatelessWidget {
  const _WelcomeBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: MaxContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _WelcomeHeader(),
                const SizedBox(height: 20),
                const FadeIn(child: _HeroPhotos()),
                const SizedBox(height: 24),
                FadeIn(
                  delay: const Duration(milliseconds: 60),
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        height: 1.15,
                        letterSpacing: -0.6,
                        color: context.palette.ink,
                      ),
                      children: [
                        TextSpan(text: 'GP care and\n'),
                        TextSpan(
                          text: 'everyday wellbeing,\n',
                          style: TextStyle(color: context.palette.positive),
                        ),
                        TextSpan(text: 'connected.'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FadeIn(
                  delay: const Duration(milliseconds: 100),
                  child: Text(
                    'GP appointments and practical support for healthier '
                    'routines, eating well and relaxation.',
                    style: TextStyle(
                      fontSize: 15,
                      color: context.palette.inkMuted,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FadeIn(
                  delay: const Duration(milliseconds: 140),
                  child: Row(
                    children: [
                      Expanded(
                        child: _FeatureIcon(
                          icon: Icons.videocam_outlined,
                          background: context.palette.tintBlue,
                          color: context.palette.accent,
                          label: 'Online GP',
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _FeatureIcon(
                          icon: Icons.location_on_outlined,
                          background: context.palette.tintGreenFaint,
                          color: context.palette.positive,
                          label: 'Clinic care',
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _FeatureIcon(
                          icon: Icons.spa_outlined,
                          background: context.palette.tintBlue,
                          color: context.palette.accent,
                          label: 'Wellbeing',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                FadeIn(
                  delay: const Duration(milliseconds: 180),
                  child: SizedBox(
                    height: 52,
                    child: FilledButton(
                      onPressed: () => context.push(RoutePaths.createAccount),
                      style: FilledButton.styleFrom(
                        backgroundColor: _welcomeBlue,
                        foregroundColor: AppColors.white,
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(
                          fontFamily: appFontFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Create an account'),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
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
                        foregroundColor: context.palette.ink,
                        side: BorderSide(
                          color: context.palette.line,
                          width: 1.5,
                        ),
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(
                          fontFamily: appFontFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
                        'For adults aged 18 and over. GP care in England.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.palette.inkMuted,
                        ),
                      ),
                      Text(
                        'For members and non-members',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.palette.inkMuted,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Terms of use  |  Privacy notice',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.palette.accent,
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

/// Two overlapping "blob" photo cards with soft decorative circles and a
/// connecting arc behind them, matching the reference design's organic
/// (not plain-rectangular) photo shapes.
class _HeroPhotos extends StatelessWidget {
  const _HeroPhotos();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Soft decorative blobs behind the photos.
          Positioned(
            right: -20,
            top: -10,
            child: _SoftBlob(
              diameter: 150,
              color: context.palette.adapt(const Color(0xFFDCF3D6)),
            ),
          ),
          Positioned(
            left: -10,
            bottom: -10,
            child: _SoftBlob(
              diameter: 120,
              color: context.palette.tintBlueStrong,
            ),
          ),
          // Connecting arc between the two photos.
          const Positioned(
            right: 24,
            top: 60,
            width: 90,
            height: 90,
            child: CustomPaint(painter: _ArcPainter()),
          ),
          // Doctor photo (top-left, larger).
          Positioned(
            left: 0,
            top: 0,
            width: 210,
            height: 192,
            child: _BlobPhoto(
              asset: 'assets/images/home/doctor.png',
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(96),
                topRight: Radius.circular(96),
                bottomLeft: Radius.circular(96),
                bottomRight: Radius.circular(26),
              ),
              badgeAlignment: Alignment.topLeft,
            ),
          ),
          // Wellbeing photo (bottom-right, smaller, overlapping).
          Positioned(
            right: 0,
            bottom: 0,
            width: 192,
            height: 172,
            child: _BlobPhoto(
              asset: 'assets/images/welcome/welcome-hero.webp',
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(86),
                bottomLeft: Radius.circular(86),
                bottomRight: Radius.circular(86),
              ),
              badgeAlignment: Alignment.bottomRight,
            ),
          ),
          const Positioned(right: 72, top: 36, child: _PlusBadge()),
        ],
      ),
    );
  }
}

class _SoftBlob extends StatelessWidget {
  const _SoftBlob({required this.diameter, required this.color});

  final double diameter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _welcomeBlue.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.75, 0)
      ..quadraticBezierTo(
        size.width * 0.1,
        size.height * 0.35,
        size.width * 0.3,
        size.height,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BlobPhoto extends StatelessWidget {
  const _BlobPhoto({
    required this.asset,
    required this.borderRadius,
    required this.badgeAlignment,
  });

  final String asset;
  final BorderRadius borderRadius;
  final Alignment badgeAlignment;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(color: context.palette.tintBlueFaint),
          ),
          Positioned.fill(child: Image.asset(asset, fit: BoxFit.cover)),
          Positioned.fill(
            child: Align(
              alignment: badgeAlignment,
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: _VideoBadge(),
              ),
            ),
          ),
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
        color: _welcomeBlue,
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
        color: _welcomeGreen,
        shape: BoxShape.circle,
        border: Border.all(color: context.palette.background, width: 3),
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
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: context.palette.ink,
          ),
        ),
      ],
    );
  }
}

/// The logo and "UK" chip, as the shared header drew them before the
/// screen-pack redesign.
class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          context.palette.logoAsset,
          height: 24,
          semanticLabel: 'LifeCome Health',
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            color: context.palette.surface,
            borderRadius: BorderRadius.circular(999),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppCountry.unitedKingdom.flag,
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(width: 4),
              Text(
                AppCountry.unitedKingdom.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.palette.ink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
