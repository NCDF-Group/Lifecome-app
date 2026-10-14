import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/core_providers.dart';
import 'core/router/app_router.dart';
import 'core/router/route_paths.dart';
import 'core/theme/app_palette.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_controller.dart';

class LifeComeLiveApp extends ConsumerWidget {
  const LifeComeLiveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    // The backend stopped accepting the saved sign-in (it expired): the
    // session has already been cleared, so go to sign in.
    ref.listen<int>(sessionExpiredProvider, (previous, next) {
      router.go(RoutePaths.signIn);
    });

    return MaterialApp.router(
      title: 'LifeCome Live',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      darkTheme: buildAppTheme(brightness: Brightness.dark),
      // System by default: the phone's light/dark setting decides, until the
      // user picks one on the Profile tab.
      themeMode: themeMode,
      builder: (context, child) =>
          _SystemUiStyle(child: child ?? const SizedBox.shrink()),
      routerConfig: router,
    );
  }
}

/// Keeps the status bar (and, on Android, the navigation bar) icons legible
/// against the page: dark icons on the light theme, light icons on the dark
/// one. Most screens draw their own header rather than an AppBar, so nothing
/// else would flip them.
class _SystemUiStyle extends StatelessWidget {
  const _SystemUiStyle({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final dark = palette.isDark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
        systemNavigationBarIconBrightness: dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: dark ? palette.background : null,
      ),
      child: child,
    );
  }
}
