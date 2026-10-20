import 'package:flutter_test/flutter_test.dart';
import 'package:lifecome_mobile/core/router/route_paths.dart';
import 'package:lifecome_mobile/features/wellbeing/presentation/wellbeing_booking_screens.dart';
import 'package:lifecome_mobile/features/wellbeing/presentation/wellbeing_screens.dart';
import 'package:lifecome_mobile/features/wellbeing/presentation/wellbeing_session_screens.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

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

  testWidgets('Home Wellbeing card opens the hub', (tester) async {
    await pumpAppAt(tester, RoutePaths.home, overrides: backend.overrides);
    await tapText(tester, 'Wellbeing');
    expect(find.byType(WellbeingHubScreen), findsOneWidget);
    expect(find.text('Small steps.\nA healthier you.'), findsOneWidget);
    expect(
      find.textContaining('Wellbeing sessions are in preview'),
      findsOneWidget,
    );

    await disposeApp(tester);
  });

  testWidgets('book, reschedule, check in and cancel a session', (
    tester,
  ) async {
    await pumpAppAt(tester, RoutePaths.wellbeing, overrides: backend.overrides);
    await tapText(tester, 'Lifestyle coaching');
    expect(find.byType(WellbeingOfferScreen), findsOneWidget);
    await tapText(tester, 'Meet your practitioner');
    expect(find.text('Jordan Ellis'), findsOneWidget);
    await tapText(tester, 'Choose a time');
    expect(find.byType(WellbeingSlotsScreen), findsOneWidget);

    // A time must be chosen first.
    await tapText(tester, '10:30');
    await tapText(tester, 'Continue');
    expect(find.byType(WellbeingReviewScreen), findsOneWidget);

    await tapText(tester, 'Confirm session');
    expect(find.text('Please confirm to continue.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'A routine for my week');
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tapText(tester, 'Confirm session');
    expect(find.byType(WellbeingConfirmedScreen), findsOneWidget);

    await tapText(tester, 'View your session');
    expect(find.byType(WellbeingSessionScreen), findsOneWidget);
    expect(find.text('Confirmed'), findsOneWidget);
    expect(find.text('10:30 · UK time'), findsOneWidget);

    await tapText(tester, 'Reschedule session');
    await tapText(tester, '14:00');
    await tapText(tester, 'Confirm new time');
    expect(find.byType(WellbeingSessionScreen), findsOneWidget);
    expect(find.text('14:00 · UK time'), findsOneWidget);

    await tapText(tester, 'Join session');
    await tapText(tester, 'Finish and view my plan');
    expect(find.byType(WellbeingPlanScreen), findsOneWidget);
    expect(find.text('A routine for my week'), findsOneWidget);
    await tapText(tester, 'My weekly check-in');
    await tapText(tester, '4');
    await tapText(tester, 'Save check-in');
    expect(find.text('4 of 5 · latest check-in'), findsOneWidget);

    await disposeApp(tester);
  });

  testWidgets('the sessions screen with nothing booked offers to explore', (
    tester,
  ) async {
    await pumpAppAt(
      tester,
      RoutePaths.wellbeingSession,
      overrides: backend.overrides,
    );
    expect(find.text('No wellbeing session booked'), findsOneWidget);

    await disposeApp(tester);
  });
}
