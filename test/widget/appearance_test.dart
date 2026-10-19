import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifecome_mobile/app.dart';
import 'package:lifecome_mobile/core/router/app_router.dart';
import 'package:lifecome_mobile/core/router/route_paths.dart';
import 'package:lifecome_mobile/core/theme/app_palette.dart';
import 'package:lifecome_mobile/core/theme/theme_mode_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_fonts.dart';

/// Pumps the real app (real router, real screens) at phone size and navigates
/// to [location].
Future<void> _pumpApp(
  WidgetTester tester, {
  ThemeMode saved = ThemeMode.system,
  Brightness phone = Brightness.light,
  String location = RoutePaths.welcome,
}) async {
  tester.view.physicalSize = const Size(390 * 2, 1400 * 2);
  tester.view.devicePixelRatio = 2.0;
  tester.platformDispatcher.platformBrightnessTestValue = phone;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [initialThemeModeProvider.overrideWithValue(saved)],
      child: const LifeComeLiveApp(),
    ),
  );
  await tester.pump();
  ProviderScope.containerOf(tester.element(find.byType(LifeComeLiveApp)))
      .read(appRouterProvider)
      .go(location);
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
}

/// Tears the app down and lets the splash screen's hold timer run out, so no
/// timer is left pending when the test ends.
Future<void> _dispose(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 3));
}

/// Lets the theme cross-fade finish: AnimatedTheme only starts on the frame
/// after the change, so one pump is not enough.
Future<void> _settleTheme(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 400));
}

BuildContext _screenContext(WidgetTester tester) =>
    tester.element(find.byType(Scaffold).first);

Brightness _shownBrightness(WidgetTester tester) =>
    Theme.of(_screenContext(tester)).brightness;

void main() {
  setUpAll(loadManrope);
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets("follows the phone's light or dark setting by default", (
    tester,
  ) async {
    await _pumpApp(tester, phone: Brightness.dark);
    expect(_shownBrightness(tester), Brightness.dark);
    expect(_screenContext(tester).palette.isDark, isTrue);

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    await _settleTheme(tester);
    expect(_shownBrightness(tester), Brightness.light);
    expect(_screenContext(tester).palette.isDark, isFalse);

    await _dispose(tester);
  });

  testWidgets("a saved choice beats the phone's setting", (tester) async {
    await _pumpApp(tester, saved: ThemeMode.dark, phone: Brightness.light);
    expect(_shownBrightness(tester), Brightness.dark);
    await _dispose(tester);

    await _pumpApp(tester, saved: ThemeMode.light, phone: Brightness.dark);
    expect(_shownBrightness(tester), Brightness.light);
    await _dispose(tester);
  });

  testWidgets('the Profile tab changes the appearance and remembers it', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'session_email': 'alex.morgan@example.com',
      'session_display_name': 'Alex Morgan',
    });
    await _pumpApp(tester, location: RoutePaths.profile);

    // Starts on system default, with the phone in light mode.
    expect(find.text('Appearance'), findsOneWidget);
    expect(
      find.text("Matches your phone's light or dark setting"),
      findsOneWidget,
    );
    expect(_shownBrightness(tester), Brightness.light);

    // Open the chooser and pick Dark.
    await tester.tap(find.text('Appearance'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('System default'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    await tester.tap(find.text('Dark'));
    await _settleTheme(tester);

    expect(_shownBrightness(tester), Brightness.dark);
    expect(find.text('Always dark'), findsOneWidget);
    expect(await ThemeModeStore().read(), ThemeMode.dark);

    // And back to following the phone.
    await tester.tap(find.text('Appearance'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('System default'));
    await _settleTheme(tester);

    expect(_shownBrightness(tester), Brightness.light);
    expect(await ThemeModeStore().read(), ThemeMode.system);

    await _dispose(tester);
  });

  testWidgets('dark mode paints the page with the dark background', (
    tester,
  ) async {
    await _pumpApp(tester, saved: ThemeMode.dark, location: RoutePaths.signIn);
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(
      scaffold.backgroundColor ??
          Theme.of(_screenContext(tester)).scaffoldBackgroundColor,
      AppPalette.dark.background,
    );
    await _dispose(tester);
  });
}
