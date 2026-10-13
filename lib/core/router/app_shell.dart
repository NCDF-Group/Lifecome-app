import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_palette.dart';

/// Hosts the five bottom-nav tabs (Home, Services, Visit, Messages, Profile
/// — view 04 onward in the blueprint) behind a `StatefulShellRoute`, so
/// switching tabs keeps each one's own navigation stack instead of losing
/// it. A hand-rolled bar rather than Material 3's `NavigationBar`: the
/// design's selected state is a thin underline below the whole item, not
/// `NavigationBar`'s pill-behind-the-icon indicator.
///
/// The tab icons are SVGs in assets/icons/nav (Heroicons and Iconsax — see
/// assets/icons/NOTICE.md), an outline for each tab and a filled twin for
/// its selected state, drawn on a 24x24 grid and tinted to the item colour.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _BottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;

  /// SVG asset paths: the outline icon, and the filled one shown when the
  /// tab is selected.
  final String icon;
  final String selectedIcon;
}

const _items = [
  _NavItem(
    label: 'Home',
    icon: 'assets/icons/nav/home.svg',
    selectedIcon: 'assets/icons/nav/home-filled.svg',
  ),
  _NavItem(
    label: 'Services',
    icon: 'assets/icons/nav/services.svg',
    selectedIcon: 'assets/icons/nav/services-filled.svg',
  ),
  _NavItem(
    label: 'Visit',
    icon: 'assets/icons/nav/visit.svg',
    selectedIcon: 'assets/icons/nav/visit-filled.svg',
  ),
  _NavItem(
    label: 'Messages',
    icon: 'assets/icons/nav/messages.svg',
    selectedIcon: 'assets/icons/nav/messages-filled.svg',
  ),
  _NavItem(
    label: 'Profile',
    icon: 'assets/icons/nav/profile.svg',
    selectedIcon: 'assets/icons/nav/profile-filled.svg',
  ),
];

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.currentIndex, required this.onSelected});

  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.palette.surface,
        border: Border(top: BorderSide(color: context.palette.line)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: _NavButton(
                    item: _items[i],
                    selected: i == currentIndex,
                    onTap: () => onSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? context.palette.accent : context.palette.inkMuted;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              selected ? item.selectedIcon : item.icon,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            const SizedBox(height: 4),
            // IntrinsicWidth so the underline below can match the label's
            // own rendered width exactly, rather than a guessed fixed size.
            IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: selected ? 1 : 0,
                    child: Container(
                      height: 2.5,
                      color: context.palette.accent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
