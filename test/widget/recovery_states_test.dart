import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifecome_mobile/app.dart';
import 'package:lifecome_mobile/core/network/api_exception.dart';
import 'package:lifecome_mobile/core/providers/core_providers.dart';
import 'package:lifecome_mobile/core/router/route_paths.dart';
import 'package:lifecome_mobile/features/auth/presentation/sign_in_screen.dart';
import 'package:lifecome_mobile/features/common_states/presentation/session_ended_screen.dart';
import 'package:lifecome_mobile/features/consultation/presentation/connection_help_screen.dart';
import 'package:lifecome_mobile/features/payer/presentation/select_hmo_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/pump_app.dart';
import '../helpers/test_backend.dart';
import '../helpers/test_fonts.dart';

void main() {
  setUpAll(loadManrope);

  late TestBackend backend;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    backend = TestBackend();
  });

  testWidgets('an expired sign-in says so, then goes to sign in', (
    tester,
  ) async {
    await pumpAppAt(tester, RoutePaths.home, overrides: backend.overrides);
    ProviderScope.containerOf(tester.element(find.byType(LifeComeLiveApp)))
        .read(sessionExpiredProvider.notifier)
        .bump();
    await settle(tester);

    expect(find.byType(SessionEndedScreen), findsOneWidget);
    expect(find.text('Your session has ended'), findsOneWidget);
    await tapText(tester, 'Sign in again');
    expect(find.byType(SignInScreen), findsOneWidget);

    await disposeApp(tester);
  });

  testWidgets('a server error reads as a temporary outage with a retry', (
    tester,
  ) async {
    backend.booking.listFailure = const ApiException(
      'Internal error',
      statusCode: 503,
    );
    await pumpAppAt(tester, RoutePaths.visits, overrides: backend.overrides);
    expect(find.text('Service temporarily unavailable'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);

    await disposeApp(tester);
  });

  testWidgets('connection help offers checks and ways forward', (tester) async {
    await pumpAppAt(
      tester,
      RoutePaths.connectionHelp,
      overrides: backend.overrides,
    );
    expect(find.byType(ConnectionHelpScreen), findsOneWidget);
    expect(find.text('Check your Wi-Fi or mobile data'), findsOneWidget);
    expect(find.text('Message the care team'), findsOneWidget);

    await disposeApp(tester);
  });

  testWidgets('a plan that cannot be verified offers another route', (
    tester,
  ) async {
    backend.payers.verifyFailure = const ApiException(
      'Your membership could not be verified (not_found).',
      code: 'MEMBERSHIP_NOT_VERIFIED',
      statusCode: 422,
    );
    await pumpAppAt(
      tester,
      RoutePaths.payerSelectHmo,
      overrides: backend.overrides,
    );
    await tapText(tester, 'Bupa');
    expect(find.text('Choose a different plan'), findsNothing);
    await tester.enterText(find.byType(TextField).first, 'BP-000000');
    await tester.pump();
    await tapText(tester, 'Verify membership');

    expect(find.text('Choose a different plan'), findsOneWidget);
    expect(find.text('Contact support'), findsOneWidget);
    await tapText(tester, 'Choose a different plan');
    expect(find.byType(SelectHmoScreen), findsOneWidget);

    await disposeApp(tester);
  });
}
