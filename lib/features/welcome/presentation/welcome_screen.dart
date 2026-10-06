import 'package:flutter/material.dart';

import '../../../core/theme/app_typography.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/animation/fade_in.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/layout/max_content_width.dart';

/// The single static screen shown after the splash screen when there is no
/// remembered session — the app's front door. A full-bleed photo behind the
/// headline and both CTAs (rather than a photo-then-white-card layout)
/// matches the app's actual welcome design, not the website's boxed hero
/// section.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/welcome/welcome-hero.webp',
            fit: BoxFit.cover,
            alignment: const Alignment(0.7, -0.3),
            semanticLabel: 'A woman smiling as she uses her phone at home',
          ),
          // Fades the photo into white at the very top (so the logo sits on
          // a soft blend rather than a hard-edged bar) and darkens it at the
          // bottom so the white headline, subtext and buttons stay readable.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 0.16, 0.4, 1],
                colors: [
                  Color(0xF2FFFFFF),
                  Color(0x00FFFFFF),
                  Color(0x00000000),
                  Color(0xCC0B2540),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                FadeIn(
                  child: SvgPicture.asset(
                    AppColors.logoAsset,
                    height: 32,
                    semanticsLabel: 'LifeCome Live',
                  ),
                ),
                const Spacer(),
                MaxContentWidth(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: Column(
                      children: [
                        FadeIn(
                          delay: const Duration(milliseconds: 80),
                          child: const Text(
                            'Quality Healthcare, Anytime, Anywhere.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: AppColors.white,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        FadeIn(
                          delay: const Duration(milliseconds: 120),
                          child: const Text(
                            'Talk to trusted doctors and access coordinated care, '
                            'all in one place. Use your HMO or pay directly.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: Column(
                            children: [
                              FadeIn(
                                delay: const Duration(milliseconds: 160),
                                child: _WelcomeButton(
                                  label: 'Log In',
                                  color: AppColors.green,
                                  onPressed: () =>
                                      context.go(RoutePaths.signIn),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              FadeIn(
                                delay: const Duration(milliseconds: 200),
                                child: _WelcomeButton(
                                  label: 'Get Started',
                                  color: AppColors.blue,
                                  onPressed: () =>
                                      context.go(RoutePaths.createAccount),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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

/// A filled pill button in either of the welcome screen's two brand colours
/// — matching [PrimaryButton]'s size and shape, but this screen is the only
/// place a green CTA sits next to a blue one, so it isn't worth generalising
/// the shared button for.
class _WelcomeButton extends StatelessWidget {
  const _WelcomeButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          textStyle: const TextStyle(
            fontFamily: appFontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
