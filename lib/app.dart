import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/core_providers.dart';
import 'core/router/app_router.dart';
import 'core/router/route_paths.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_controller.dart';

class LifeComeLiveApp extends ConsumerWidget {
  const LifeComeLiveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    // If the backend rejects our session token (expired or revoked), forget it and send the user to the
    // lock screen to sign in again with their password.
    ref.read(apiClientProvider).onUnauthorized = () {
      ref.read(apiClientProvider).accessToken = null;
      ref.read(sessionStoreProvider).clearToken();
      router.go(RoutePaths.appLock);
    };

    return MaterialApp.router(
      title: 'LifeCome Live',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        // Switch the colour palette to match the resolved theme *before* any screen builds. The palette is
        // global, so when the brightness changes the whole tree is rebuilt (the key), not just the widgets
        // that happen to depend on the theme.
        final brightness = Theme.of(context).brightness;
        AppColors.useBrightness(brightness);
        final dark = brightness == Brightness.dark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
            statusBarBrightness: dark ? Brightness.dark : Brightness.light,
            systemNavigationBarColor: AppColors.background,
            systemNavigationBarIconBrightness: dark
                ? Brightness.light
                : Brightness.dark,
          ),
          child: KeyedSubtree(key: ValueKey(brightness), child: child!),
        );
      },
    );
  }
}
