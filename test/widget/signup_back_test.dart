import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lifecome_mobile/app.dart';
import 'package:lifecome_mobile/core/router/app_router.dart';
import 'package:lifecome_mobile/core/router/route_paths.dart';
import 'package:lifecome_mobile/features/auth/presentation/create_account_screen.dart';
import 'package:lifecome_mobile/features/auth/presentation/sign_in_screen.dart';
import 'package:lifecome_mobile/features/welcome/presentation/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_fonts.dart';

/// Pumps the real app (real router, real screens) at phone size, sends it to
/// [location], and returns the router.
Future<GoRouter> _pumpAt(WidgetTester tester, String location) async {
  tester.view.physicalSize = const Size(390 * 2, 1400 * 2);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const ProviderScope(child: LifeComeLiveApp()));
  await tester.pump();
  final router = ProviderScope.containerOf(
    tester.element(find.byType(LifeComeLiveApp)),
  ).read(appRouterProvider);
  router.go(location);
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
  return router;
}

/// Tears the app down and lets the splash screen's hold timer run out, so no
/// timer is left pending when the test ends.
Future<void> _dispose(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 3));
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _tapBack(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
  await _settle(tester);
}

void main() {
  setUpAll(loadManrope);
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('back on the sign-up form returns to the welcome screen', (
    tester,
  ) async {
    await _pumpAt(tester, RoutePaths.welcome);
    expect(find.byType(WelcomeScreen), findsOneWidget);

    await tester.tap(find.text('Create an account'));
    await _settle(tester);
    expect(find.byType(CreateAccountScreen), findsOneWidget);

    await _tapBack(tester);
    expect(find.byType(CreateAccountScreen), findsNothing);
    expect(find.byType(WelcomeScreen), findsOneWidget);

    await _dispose(tester);
  });

  testWidgets('back still works when nothing is behind the sign-up form', (
    tester,
  ) async {
    // e.g. the form was opened straight from a link, or restored on its own.
    await _pumpAt(tester, RoutePaths.createAccount);
    expect(find.byType(CreateAccountScreen), findsOneWidget);

    await _tapBack(tester);
    expect(find.byType(CreateAccountScreen), findsNothing);
    expect(find.byType(WelcomeScreen), findsOneWidget);

    await _dispose(tester);
  });

  testWidgets('back returns to sign in when the form was opened from there', (
    tester,
  ) async {
    await _pumpAt(tester, RoutePaths.signIn);
    expect(find.byType(SignInScreen), findsOneWidget);

    await tester.tap(find.text('Create an account'));
    await _settle(tester);
    expect(find.byType(CreateAccountScreen), findsOneWidget);

    await _tapBack(tester);
    expect(find.byType(CreateAccountScreen), findsNothing);
    expect(find.byType(SignInScreen), findsOneWidget);

    await _dispose(tester);
  });
}
