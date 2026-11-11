import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/preferences/device_preferences.dart';
import 'core/providers/core_providers.dart';
import 'core/router/app_router.dart';
import 'core/router/route_paths.dart';
import 'core/theme/app_palette.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_controller.dart';

class LifeComeHealthApp extends ConsumerWidget {
  const LifeComeHealthApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    // The backend stopped accepting the saved sign-in (it expired): the
    // session has already been cleared, so say so, then sign in again.
    ref.listen<int>(sessionExpiredProvider, (previous, next) {
      router.go(RoutePaths.sessionEnded);
    });

    return MaterialApp.router(
      title: 'LifeCome Health',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      darkTheme: buildAppTheme(brightness: Brightness.dark),
      // System by default: the phone's light/dark setting decides, until the
      // user picks one on the Profile tab.
      themeMode: themeMode,
      builder: (context, child) => _ResponsiveFrame(
        child: _Accessibility(
          child: _SystemUiStyle(child: child ?? const SizedBox.shrink()),
        ),
      ),
      routerConfig: router,
    );
  }
}

/// Makes the app fit every screen: text shrinks a little on narrow phones so
/// headlines and buttons keep to one or two lines, and on tablets, desktops
/// and wide browser windows the content stays in a centred phone-width column
/// instead of stretching edge to edge.
class _ResponsiveFrame extends StatelessWidget {
  const _ResponsiveFrame({required this.child});

  final Widget child;

  static const double _maxContentWidth = 720;

  /// Text scale for a screen [width] in logical pixels.
  static double textFactorFor(double width) {
    if (width < 320) return 0.82;
    if (width < 360) return 0.88;
    if (width < 400) return 0.94;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final factor = textFactorFor(width);

    Widget framed = child;
    if (width > _maxContentWidth) {
      framed = Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxContentWidth),
          child: MediaQuery(
            data: media.copyWith(
              size: Size(_maxContentWidth, media.size.height),
            ),
            child: child,
          ),
        ),
      );
    }
    if (factor == 1) return framed;
    return MediaQuery(
      data: media.copyWith(
        textScaler: TextScaler.linear(media.textScaler.scale(1) * factor),
      ),
      child: framed,
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

/// Applies the Accessibility settings app-wide: larger text scales every
/// piece of text up by 15% on top of the phone's own setting, and reduce
/// motion turns animations off.
class _Accessibility extends ConsumerWidget {
  const _Accessibility({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(devicePreferencesProvider);
    final larger = prefs[DevicePreferences.largerText] ?? false;
    final calm = prefs[DevicePreferences.reduceMotion] ?? false;
    if (!larger && !calm) return child;

    final media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(
        textScaler: larger
            ? TextScaler.linear(media.textScaler.scale(1) * 1.15)
            : media.textScaler,
        disableAnimations: calm || media.disableAnimations,
      ),
      child: child,
    );
  }
}
