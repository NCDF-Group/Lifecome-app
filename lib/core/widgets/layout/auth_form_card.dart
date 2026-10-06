import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

/// A centred, generously wide, rounded card for a form-based screen (sign
/// in, create account). On a phone this reads as a soft floating card
/// rather than edge-to-edge fields; on a wider screen (tablet) it keeps the
/// form from stretching uncomfortably wide by capping at [maxWidth].
class AuthFormCard extends StatelessWidget {
  const AuthFormCard({super.key, required this.child, this.maxWidth = 460});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: child,
        ),
      ),
    );
  }
}
