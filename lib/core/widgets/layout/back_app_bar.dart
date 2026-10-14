import 'package:flutter/material.dart';

import '../../router/route_paths.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_spacing.dart';
import 'app_bar_back.dart';

/// The top bar for a screen that has a title and a way back: the back arrow
/// on the left (see [AppBackButton]), the title in the middle, and any
/// [actions] on the right. Use it instead of a bare `AppBar` so every screen's
/// back arrow looks and behaves the same.
class BackAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BackAppBar({
    super.key,
    this.title,
    this.fallback = RoutePaths.home,
    this.onBack,
    this.actions,
  });

  final String? title;

  /// Where back goes when there is no previous screen.
  final String fallback;

  /// Replaces the default "go back one screen" (to confirm first, say).
  final VoidCallback? onBack;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leadingWidth: 56,
      leading: Padding(
        padding: const EdgeInsets.only(left: AppSpacing.xs),
        child: AppBackButton(fallback: fallback, onPressed: onBack),
      ),
      title: title == null
          ? null
          : Text(
              title!,
              style: TextStyle(
                color: context.palette.ink,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
      actions: actions,
    );
  }
}
