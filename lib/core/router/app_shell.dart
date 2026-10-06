import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_icons.dart';

/// Hosts the four bottom-nav tabs (Home, Visits, Messages, Profile — view 04
/// onward in the blueprint) behind a `StatefulShellRoute`, so switching tabs
/// keeps each one's own navigation stack instead of losing it. Uses Material
/// 3's own `NavigationBar` (styled via `navigationBarTheme` in app_theme.dart)
/// rather than a hand-rolled bar, for its built-in indicator pill, motion and
/// platform-consistent behaviour.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: HouseNavIcon(),
            selectedIcon: HouseNavIcon(filled: true),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Visits',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle_outlined),
            selectedIcon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
