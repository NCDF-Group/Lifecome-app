import 'package:flutter/material.dart';

import '../../../features/notifications/presentation/widgets/notifications_bell.dart';
import '../../country/app_country.dart';
import '../../router/route_paths.dart';
import '../../theme/app_palette.dart';
import '../../router/safe_back.dart';
import '../media/lc_icons.dart';

/// The header shared by Home and the screens reached from it (the screen
/// pack's `.app-header`): an optional back arrow, the logo, a static "UK"
/// chip and the notification bell (see [NotificationsBell]), with an optional
/// blue "‹ Back" link below ([BackLink]).
///
/// The back link goes to the previous screen, or to [backFallback] when
/// nothing is behind this one, so it always does something. Pass [onBack] only
/// when a screen has to do something else first.
class AppHeaderBar extends StatelessWidget {
  const AppHeaderBar({
    super.key,
    this.showBack = false,
    this.onBack,
    this.backFallback = RoutePaths.home,
    this.showBell = true,
  });

  final bool showBack;
  final VoidCallback? onBack;
  final String backFallback;

  /// False before sign-in (the welcome screen), where there is nothing to
  /// be notified about.
  final bool showBell;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBack) ...[
          Tooltip(
            message: 'Back',
            child: InkWell(
              onTap: onBack ?? () => context.goBack(fallback: backFallback),
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: 32,
                height: 40,
                child: Center(
                  child: LcIcon(
                    LcIcons.back,
                    size: 24,
                    color: context.palette.ink,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
        Image.asset(
          context.palette.logoAsset,
          height: 28,
          semanticLabel: 'LifeCome Health',
        ),
        const Spacer(),
        const _CountryChip(),
        if (showBell) ...[const SizedBox(width: 8), const NotificationsBell()],
      ],
    );
  }
}

class _CountryChip extends StatelessWidget {
  const _CountryChip();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppCountry.unitedKingdom.name,
      excludeSemantics: true,
      child: Container(
        decoration: BoxDecoration(
          color: context.palette.surface,
          border: Border.all(color: context.palette.tintBlueLine),
          borderRadius: BorderRadius.circular(999),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppCountry.unitedKingdom.flag,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(width: 5),
            Text(
              'UK',
              style: TextStyle(
                fontSize: 14,
                height: 1,
                fontWeight: FontWeight.w700,
                color: context.palette.ink,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: context.palette.ink,
            ),
          ],
        ),
      ),
    );
  }
}
