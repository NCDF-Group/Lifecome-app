import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../country/app_country.dart';
import '../../theme/app_colors.dart';
import '../feedback/app_popup.dart';

/// The header shared by the welcome screen, Home, Services and the
/// wellbeing detail screens: an optional back arrow, the logo, a static
/// "UK" chip, and the notification bell. Matches the consistent top bar
/// across those design screenshots.
class AppHeaderBar extends StatelessWidget {
  const AppHeaderBar({super.key, this.showBack = false, this.onBack});

  final bool showBack;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBack) ...[
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: onBack ?? () => context.pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(width: 8),
        ],
        SvgPicture.asset(
          'assets/images/logo/lifecome-live-logo.svg',
          height: 24,
          semanticsLabel: 'LifeCome Live',
        ),
        const Spacer(),
        const _CountryChip(),
        const SizedBox(width: 8),
        _BellButton(onTap: () => showNotificationsPopup(context)),
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
        color: AppColors.surface,
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
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _BellButton extends StatelessWidget {
  const _BellButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 38,
          height: 38,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.notifications_outlined,
                size: 20,
                color: AppColors.ink,
              ),
              Positioned(top: 8, right: 9, child: _Dot()),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: AppColors.blue,
        shape: BoxShape.circle,
      ),
    );
  }
}
