import 'package:flutter/material.dart';

import '../../../features/notifications/presentation/widgets/notifications_bell.dart';
import '../../country/app_country.dart';
import '../../router/route_paths.dart';
import '../../theme/app_palette.dart';
import 'app_bar_back.dart';

/// The header shared by Home, Services and the screens reached from them: an
/// optional back arrow, the logo, a static "UK" chip, and the notification
/// bell (see [NotificationsBell]).
///
/// The back arrow goes to the previous screen, or to [backFallback] when
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
          AppBackButton(fallback: backFallback, onPressed: onBack),
          const SizedBox(width: 8),
        ],
        Image.asset(
          context.palette.logoAsset,
          height: 24,
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
    return Container(
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
    );
  }
}
