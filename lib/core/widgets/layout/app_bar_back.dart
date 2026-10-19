import 'package:flutter/material.dart';

import '../../router/route_paths.dart';
import '../../router/safe_back.dart';
import '../../theme/app_palette.dart';

/// The back arrow used at the top of every screen that isn't a tab root.
///
/// It goes back one screen, or to [fallback] when nothing is behind this one
/// (see [SafeBack]), so it always does something. The arrow is drawn at the
/// left edge but the tap area is 40 by 44 points, which is what a thumb needs.
class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    this.fallback = RoutePaths.home,
    this.onPressed,
    this.color,
  });

  /// Where to go when there is no previous screen.
  final String fallback;

  /// Replaces the default "go back one screen", for a screen that has to
  /// confirm first (a half-filled form, a booking in progress).
  final VoidCallback? onPressed;

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      onPressed: onPressed ?? () => context.goBack(fallback: fallback),
      padding: EdgeInsets.zero,
      alignment: Alignment.centerLeft,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 44),
      icon: Icon(
        Icons.arrow_back_ios_new,
        size: 18,
        color: color ?? context.palette.ink,
      ),
    );
  }
}

/// The blue "‹ Back" link under the header on screens below a tab root (the
/// screen pack's `.back`). Same behaviour as [AppBackButton].
class BackLink extends StatelessWidget {
  const BackLink({super.key, this.fallback = RoutePaths.home, this.onPressed});

  final String fallback;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final color = context.palette.accent;
    return Align(
      alignment: Alignment.centerLeft,
      child: Tooltip(
        message: 'Back',
        child: InkWell(
          onTap: onPressed ?? () => context.goBack(fallback: fallback),
          borderRadius: BorderRadius.circular(8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back_ios_new, size: 14, color: color),
                const SizedBox(width: 6),
                Text(
                  'Back',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
                const SizedBox(width: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
