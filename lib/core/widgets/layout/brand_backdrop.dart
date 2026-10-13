import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_palette.dart';

/// A soft, centred colour glow behind a form card, matching the website's
/// hero background treatment (Lifecome-web's blurred `bg-cyan`/`bg-lime`
/// circles). Purely decorative: wrap a screen's body in a [Stack] with this
/// behind an [AuthFormCard].
class BrandBackdrop extends StatelessWidget {
  const BrandBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    // The same tint reads far stronger over a dark page, so ease it off there.
    final strength = context.palette.isDark ? 0.5 : 1.0;

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -40,
            left: -60,
            child: _glow(
              300,
              AppColors.cyan.withValues(alpha: 0.20 * strength),
            ),
          ),
          Positioned(
            top: 40,
            right: -70,
            child: _glow(
              260,
              AppColors.lime.withValues(alpha: 0.20 * strength),
            ),
          ),
          Positioned(
            bottom: -80,
            left: 40,
            child: _glow(
              220,
              AppColors.blue.withValues(alpha: 0.08 * strength),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glow(double size, Color color) {
    // ImageFiltered blurs this widget's own rendering (matching the
    // website's CSS `blur-3xl` on a solid div), unlike BackdropFilter,
    // which blurs whatever is drawn behind it instead.
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
