import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/app_radius.dart';

/// A frosted-glass pill button for use over a photo (the onboarding
/// screen's Skip / Get started control): a blurred, semi-transparent white
/// fill with a soft border, rather than a solid colour, so it reads as
/// glass over whatever image sits behind it.
class GlassButton extends StatelessWidget {
  const GlassButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              onTap: onPressed,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 11,
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
