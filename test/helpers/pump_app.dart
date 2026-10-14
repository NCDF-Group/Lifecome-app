import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lifecome_mobile/app.dart';
import 'package:lifecome_mobile/core/providers/core_providers.dart';
import 'package:lifecome_mobile/core/router/app_router.dart';

/// Pumps the real app (real router, real screens) at phone size, sends it to
/// [location], and returns the router. [overrides] swap the backend-facing
/// providers for fakes, so no test ever touches the network.
Future<GoRouter> pumpAppAt(
  WidgetTester tester,
  String location, {
  List<Override> overrides = const [],
  Object? extra,
}) async {
  tester.view.physicalSize = const Size(390 * 2, 1400 * 2);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      retry: noAutomaticRetry,
      overrides: overrides,
      child: const LifeComeLiveApp(),
    ),
  );
  await tester.pump();
  final router = ProviderScope.containerOf(
    tester.element(find.byType(LifeComeLiveApp)),
  ).read(appRouterProvider);
  router.go(location, extra: extra);
  await settle(tester);
  return router;
}

/// Lets page transitions and fade-ins finish. `pumpAndSettle` is not used
/// because the splash hold timer and the OTP countdown keep scheduling frames.
Future<void> settle(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
}

/// Tears the app down and lets the splash screen's hold timer run out, so no
/// timer is left pending when the test ends.
Future<void> disposeApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 3));
}

/// Scrolls [finder] into view, taps it and lets the result settle.
Future<void> tapText(WidgetTester tester, String text) async {
  final finder = find.text(text);
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await settle(tester);
}

/// Taps the back arrow at the top of the screen.
Future<void> tapBack(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
  await settle(tester);
}
