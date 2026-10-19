import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifecome_mobile/core/router/route_paths.dart';
import 'package:lifecome_mobile/features/booking/presentation/before_your_visit_screen.dart';
import 'package:lifecome_mobile/features/profile/data/health_profile_store.dart';
import 'package:lifecome_mobile/features/profile/presentation/accessibility_screen.dart';
import 'package:lifecome_mobile/features/profile/presentation/health_profile_screen.dart';
import 'package:lifecome_mobile/features/profile/presentation/notification_settings_screen.dart';
import 'package:lifecome_mobile/features/profile/presentation/payment_methods_screen.dart';
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
  });

  testWidgets('every new profile row opens its screen', (tester) async {
    await pumpAppAt(tester, RoutePaths.profile, overrides: backend.overrides);
    for (final (label, screen) in [
      ('Health profile', HealthProfileScreen),
      ('Payment methods', PaymentMethodsScreen),
      ('Notifications', NotificationSettingsScreen),
      ('Accessibility', AccessibilityScreen),
    ]) {
      await tapText(tester, label);
      expect(find.byType(screen), findsOneWidget, reason: label);
      await tapBack(tester);
    }

    await disposeApp(tester);
  });

  testWidgets('the health profile is saved and offered when booking', (
    tester,
  ) async {
    await pumpAppAt(
      tester,
      RoutePaths.healthProfile,
      overrides: backend.overrides,
    );
    await tester.enterText(find.byType(TextField).at(1), 'Inhaler');
    await tester.enterText(find.byType(TextField).at(2), 'Penicillin');
    await tapText(tester, 'Save health profile');
    expect(find.text('Health profile saved'), findsOneWidget);

    final saved = await backend.healthProfiles.read('account-1');
    expect(saved.medicines, 'Inhaler');
    expect(saved.allergies, 'Penicillin');
    expect(saved.conditions, isNull);
    await disposeApp(tester);

    // The intake form starts from it.
    backend.booking.availability = {
      'doc-okoro': [testSlot('slot-a', 'doc-okoro', days: 1)],
    };
    await pumpAppAt(tester, RoutePaths.gp, overrides: backend.overrides);
    await tapText(tester, 'Online GP');
    await tester.enterText(find.byType(TextField).at(0), 'Leeds');
    await tester.enterText(find.byType(TextField).at(1), 'LS1 4AB');
    await tapText(
      tester,
      'I understand this is a routine appointment and not emergency care.',
    );
    await tapText(tester, 'Continue');
    await tapText(tester, 'Continue');
    await tester.tap(
      find
          .text(ukClock(backend.booking.availability['doc-okoro']!.first))
          .first,
    );
    await settle(tester);
    expect(find.byType(BeforeYourVisitScreen), findsOneWidget);
    expect(
      find.text('Medicines: Inhaler\nAllergies: Penicillin'),
      findsOneWidget,
    );

    await disposeApp(tester);
  });

  testWidgets('larger text applies straight away and is remembered', (
    tester,
  ) async {
    await pumpAppAt(
      tester,
      RoutePaths.accessibility,
      overrides: backend.overrides,
    );
    final title = find.text('Make it yours');
    double scale() => MediaQuery.textScalerOf(tester.element(title)).scale(1);
    expect(scale(), 1);

    await tapText(tester, 'Larger text');
    expect(scale(), closeTo(1.15, 0.001));
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('pref_larger_text'), isTrue);

    await disposeApp(tester);
  });

  testWidgets('notification choices are remembered on the device', (
    tester,
  ) async {
    await pumpAppAt(
      tester,
      RoutePaths.notificationSettings,
      overrides: backend.overrides,
    );
    await tapText(tester, 'Order updates');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('pref_order_updates'), isFalse);

    await disposeApp(tester);
  });

  testWidgets('payment methods says cards are not stored', (tester) async {
    await pumpAppAt(
      tester,
      RoutePaths.paymentMethods,
      overrides: backend.overrides,
    );
    expect(find.text('Pay when you book'), findsOneWidget);
    expect(find.textContaining('••••'), findsNothing);

    await disposeApp(tester);
  });

  test('health profile joins medicines and allergies for the intake', () {
    expect(const HealthProfile().medicinesAndAllergies, isNull);
    expect(
      const HealthProfile(allergies: 'None').medicinesAndAllergies,
      'Allergies: None',
    );
  });
}
