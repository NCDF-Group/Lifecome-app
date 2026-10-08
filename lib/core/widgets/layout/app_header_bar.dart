import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../country/app_country.dart';
import '../../theme/app_colors.dart';
import '../feedback/app_popup.dart';

/// The header shared by the welcome screen, Home and the services screens:
/// the logo, a tappable country chip, and the notification bell. Matches
/// the consistent top bar across those design screenshots.
class AppHeaderBar extends ConsumerWidget {
  const AppHeaderBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final country = ref.watch(countryProvider);

    return Row(
      children: [
        SvgPicture.asset(
          'assets/images/logo/lifecome-live-logo.svg',
          height: 24,
          semanticsLabel: 'LifeCome Live',
        ),
        const Spacer(),
        _CountryChip(country: country, onTap: () => _pickCountry(context, ref)),
        const SizedBox(width: 8),
        _BellButton(onTap: () => showNotificationsPopup(context)),
      ],
    );
  }

  Future<void> _pickCountry(BuildContext context, WidgetRef ref) async {
    final picked = await showCountryPickerPopup(
      context,
      current: ref.read(countryProvider),
    );
    if (picked != null) await ref.read(countryProvider.notifier).select(picked);
  }
}

class _CountryChip extends StatelessWidget {
  const _CountryChip({required this.country, required this.onTap});

  final AppCountry country;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(country.flag, style: const TextStyle(fontSize: 15)),
              const SizedBox(width: 4),
              Text(
                country.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: AppColors.inkMuted,
              ),
            ],
          ),
        ),
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
