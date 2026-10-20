import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifecome_mobile/core/router/route_paths.dart';
import 'package:lifecome_mobile/features/care/presentation/care_hub_screens.dart';
import 'package:lifecome_mobile/features/care/presentation/care_journey_screens.dart';
import 'package:lifecome_mobile/features/care/presentation/care_request_screen.dart';
import 'package:lifecome_mobile/features/care/presentation/care_visits_screens.dart';
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

  Finder field(int index) => find.byType(TextField).at(index);

  testWidgets('Home Care card opens the hub, which says it is a preview', (
    tester,
  ) async {
    await pumpAppAt(tester, RoutePaths.home, overrides: backend.overrides);
    await tapText(tester, 'Care');
    expect(find.byType(CareHubScreen), findsOneWidget);
    expect(find.text('Care that feels personal'), findsOneWidget);
    expect(
      find.textContaining('Professional Care is in preview'),
      findsOneWidget,
    );

    await disposeApp(tester);
  });

  testWidgets('a request goes through proposal, agreement and visits', (
    tester,
  ) async {
    await pumpAppAt(tester, RoutePaths.care, overrides: backend.overrides);
    expect(find.text('Request care'), findsOneWidget);
    await tapText(tester, 'Request care');
    expect(find.byType(CareRequestScreen), findsOneWidget);

    // Step 1: postcode and permission are required.
    await tapText(tester, 'Continue');
    expect(find.text('STEP 1 OF 4'), findsOneWidget);
    await tester.enterText(field(0), 'Alex Morgan');
    await tester.enterText(field(1), 'LS1 4AB');
    await tapText(
      tester,
      'I have permission to share the care recipient’s information.',
    );
    await tapText(tester, 'Continue');

    // Step 2: what support.
    expect(find.text('STEP 2 OF 4'), findsOneWidget);
    await tester.enterText(field(0), 'Help with morning routines please');
    await tapText(tester, 'Continue');

    // Step 3: schedule and phone.
    expect(find.text('STEP 3 OF 4'), findsOneWidget);
    await tester.enterText(field(0), '07700 900123');
    await tapText(tester, 'Continue');

    // Step 4: review needs consent.
    expect(find.text('Review your care request'), findsOneWidget);
    await tapText(tester, 'Send care request');
    expect(find.text('Please confirm to continue.'), findsOneWidget);
    await tapText(
      tester,
      'I agree that the care coordination team can contact me about this '
      'request.',
    );
    await tapText(tester, 'Send care request');
    expect(find.byType(CareSubmittedScreen), findsOneWidget);
    expect(find.textContaining('LC-CARE-'), findsOneWidget);

    await tapText(tester, 'Track your request');
    expect(find.byType(CareStatusScreen), findsOneWidget);
    expect(find.text('Assessment requested'), findsOneWidget);

    await tapText(tester, 'Preview your care proposal');
    expect(find.text('3 visits per week'), findsOneWidget);
    expect(find.text('£180.00'), findsOneWidget);

    await tapText(tester, 'Review care agreement');
    await tapText(tester, 'Accept care plan');
    expect(find.text('Please confirm to continue.'), findsOneWidget);
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tapText(tester, 'Accept care plan');
    expect(find.byType(CarePlanDetailScreen), findsOneWidget);
    expect(find.text('Agreed'), findsOneWidget);

    await tapText(tester, 'View care visits');
    expect(find.byType(CareVisitsScreen), findsOneWidget);
    expect(find.textContaining('09:00 · Taylor Brooks'), findsWidgets);

    await disposeApp(tester);
  });

  testWidgets('before any request, journey screens offer to start one', (
    tester,
  ) async {
    await pumpAppAt(tester, RoutePaths.carePlan, overrides: backend.overrides);
    expect(find.text('No care requested yet'), findsOneWidget);
    await tapText(tester, 'Request care');
    expect(find.byType(CareRequestScreen), findsOneWidget);

    await disposeApp(tester);
  });

  testWidgets('a change request leaves the arrangement as it is', (
    tester,
  ) async {
    await pumpAppAt(
      tester,
      RoutePaths.careChange,
      overrides: backend.overrides,
    );
    await tapText(tester, 'Send change request');
    expect(find.byType(CareChangeScreen), findsOneWidget);
    await tester.enterText(field(0), 'Could visits move to the afternoon?');
    await tapText(tester, 'Send change request');
    expect(find.byType(CareChangeSentScreen), findsOneWidget);
    expect(
      find.textContaining('existing care arrangement has not changed'),
      findsOneWidget,
    );

    await disposeApp(tester);
  });
}
