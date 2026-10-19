import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifecome_mobile/core/router/route_paths.dart';
import 'package:lifecome_mobile/features/booking/presentation/before_your_visit_screen.dart';
import 'package:lifecome_mobile/features/booking/presentation/choose_service_screen.dart';
import 'package:lifecome_mobile/features/booking/presentation/find_smart_gp_clinic_screen.dart';
import 'package:lifecome_mobile/features/doctors/presentation/find_a_doctor_screen.dart';
import 'package:lifecome_mobile/features/gp/presentation/gp_eligibility_screen.dart';
import 'package:lifecome_mobile/features/gp/presentation/gp_hub_screen.dart';
import 'package:lifecome_mobile/features/menopause/presentation/menopause_booking_screen.dart';
import 'package:lifecome_mobile/features/menopause/presentation/menopause_hub_screen.dart';
import 'package:lifecome_mobile/features/menopause/presentation/menopause_plan_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fixtures.dart';
import '../helpers/pump_app.dart';
import '../helpers/test_backend.dart';
import '../helpers/test_fonts.dart';

void main() {
  setUpAll(loadManrope);

  late TestBackend backend;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    backend = TestBackend();
    backend.booking.availability = {
      'doc-okoro': [testSlot('slot-a', 'doc-okoro', days: 1)],
    };
  });

  Finder field(int index) => find.byType(TextField).at(index);

  group('GP hub', () {
    testWidgets('Home GP card opens the hub', (tester) async {
      await pumpAppAt(tester, RoutePaths.home, overrides: backend.overrides);
      await tapText(tester, 'GP');
      expect(find.byType(GpHubScreen), findsOneWidget);
      expect(find.text('GP care, your way'), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('online GP: eligibility, then reason, then GPs', (
      tester,
    ) async {
      await pumpAppAt(tester, RoutePaths.gp, overrides: backend.overrides);
      await tapText(tester, 'Online GP');
      expect(find.byType(GpEligibilityScreen), findsOneWidget);
      expect(find.text('STEP 1 OF 6'), findsOneWidget);

      await tester.enterText(field(0), 'Leeds');
      await tester.enterText(field(1), 'ls1 4ab');
      await tapText(tester, 'Continue');
      // Not an emergency is required.
      expect(find.byType(GpEligibilityScreen), findsOneWidget);
      expect(
        find.text('Please confirm this is not an emergency.'),
        findsOneWidget,
      );

      await tapText(
        tester,
        'I understand this is a routine appointment and not emergency care.',
      );
      await tapText(tester, 'Continue');
      expect(find.byType(ChooseServiceScreen), findsOneWidget);
      expect(find.text('What can we help with?'), findsOneWidget);
      // The visit type was chosen on the hub, so it is not asked again.
      expect(find.text('How would you like to be seen?'), findsNothing);

      // Where they will be was given already: straight to the GPs.
      await tapText(tester, 'Continue');
      expect(find.byType(FindADoctorScreen), findsOneWidget);
      expect(find.text('Choose your GP'), findsOneWidget);

      await tester.tap(
        find
            .text(ukClock(backend.booking.availability['doc-okoro']!.first))
            .first,
      );
      await settle(tester);
      expect(find.byType(BeforeYourVisitScreen), findsOneWidget);
      expect(find.text('Help your GP prepare'), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('in-clinic GP goes to the clinic finder for that town', (
      tester,
    ) async {
      await pumpAppAt(tester, RoutePaths.gp, overrides: backend.overrides);
      await tapText(tester, 'In-clinic GP');
      await tester.enterText(field(0), 'Leeds');
      await tester.enterText(field(1), 'LS1 4AB');
      await tapText(
        tester,
        'I understand this is a routine appointment and not emergency care.',
      );
      await tapText(tester, 'Continue');

      expect(find.byType(FindSmartGpClinicScreen), findsOneWidget);
      expect(find.text('Visit a GP in person'), findsOneWidget);

      await disposeApp(tester);
    });
  });

  group('Menopause Care', () {
    testWidgets('the assessment is saved and leads to booking', (tester) async {
      await pumpAppAt(
        tester,
        RoutePaths.menopause,
        overrides: backend.overrides,
      );
      expect(find.byType(MenopauseHubScreen), findsOneWidget);
      await tapText(tester, 'Start your assessment');

      expect(find.text('STEP 1 OF 3'), findsOneWidget);
      await tapText(tester, 'Continue');
      // What matters most is required.
      expect(find.text('STEP 1 OF 3'), findsOneWidget);
      await tester.enterText(field(0), 'Talk about sleep and options');
      await tapText(tester, 'Continue');

      expect(find.text('Your health background'), findsOneWidget);
      await tapText(tester, 'Continue');
      expect(find.text('Please confirm to continue.'), findsOneWidget);
      await tapText(tester, 'I agree to share this assessment with my GP.');
      await tapText(tester, 'Continue');

      expect(find.text('Review your assessment'), findsOneWidget);
      expect(find.text('Talk about sleep and options'), findsOneWidget);
      await tapText(tester, 'Save and choose an appointment');

      expect(find.byType(MenopauseBookingScreen), findsOneWidget);
      expect(
        find.text('Your assessment will be available to the GP.'),
        findsOneWidget,
      );

      await disposeApp(tester);
    });

    testWidgets('the plan does not invent treatment', (tester) async {
      await pumpAppAt(
        tester,
        RoutePaths.menopausePlan,
        overrides: backend.overrides,
      );
      expect(find.byType(MenopausePlanScreen), findsOneWidget);
      expect(find.text('Not started'), findsOneWidget);
      expect(find.text('Treatment and HRT'), findsOneWidget);
      expect(find.text('Start your assessment'), findsOneWidget);

      await disposeApp(tester);
    });
  });
}
