import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_palette.dart';
import '../widgets/media/lc_icons.dart';

/// Hosts the four bottom-nav tabs (Home, Visits, Messages, Profile — the
/// screen pack's shared navigation) behind a `StatefulShellRoute`, so
/// switching tabs keeps each one's own navigation stack instead of losing
/// it. A hand-rolled bar rather than Material 3's `NavigationBar`: the
/// design's selected state is just the blue colour and a heavier stroke, not
/// `NavigationBar`'s pill-behind-the-icon indicator.
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
  const _NavItem({required this.label, required this.icon});

  final String label;

  /// One of the [LcIcons] that has a bold twin for the selected state.
  final String icon;
}

const _items = [
  _NavItem(label: 'Home', icon: LcIcons.home),
  _NavItem(label: 'Visits', icon: LcIcons.calendar),
  _NavItem(label: 'Messages', icon: LcIcons.message),
  _NavItem(label: 'Profile', icon: LcIcons.user),
];

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.currentIndex, required this.onSelected});

  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.palette.background,
        border: Border(top: BorderSide(color: context.palette.line)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
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
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LcIcon(item.icon, size: 23, color: color, bold: selected),
            const SizedBox(height: 5),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
