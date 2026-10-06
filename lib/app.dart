import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/core_providers.dart';
import 'core/router/app_router.dart';
import 'core/router/route_paths.dart';
import 'core/theme/app_theme.dart';

class LifeComeLiveApp extends ConsumerWidget {
  const LifeComeLiveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

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
      theme: buildAppTheme(),
      routerConfig: router,
    );
  }
}
