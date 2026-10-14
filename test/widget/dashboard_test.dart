import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifecome_mobile/core/router/route_paths.dart';
import 'package:lifecome_mobile/features/booking/presentation/manage_appointment_screen.dart';
import 'package:lifecome_mobile/features/dashboard/presentation/dashboard_screen.dart';
import 'package:lifecome_mobile/features/emergency/presentation/emergency_guidance_screen.dart';
import 'package:lifecome_mobile/features/profile/presentation/edit_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_profile_repository.dart';
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

  testWidgets('greets the person by the name on their profile', (tester) async {
    await pumpAppAt(tester, RoutePaths.home, overrides: backend.overrides);

    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.textContaining(', Alex'), findsOneWidget);
    expect(find.text('Your next visit'), findsNothing);
    expect(find.text('Finish setting up your profile'), findsNothing);

    await disposeApp(tester);
  });

  testWidgets('shows the next real visit and opens it', (tester) async {
    backend.booking.appointments = [
      testAppointment(id: 'next-1', serviceName: 'GP Consultation'),
    ];
    await pumpAppAt(tester, RoutePaths.home, overrides: backend.overrides);

    expect(find.text('Your next visit'), findsOneWidget);
    expect(find.textContaining('GP Consultation ·'), findsOneWidget);
    expect(find.text('with Dr Sam Okoro'), findsOneWidget);

    await tester.tap(find.text('Your next visit'));
    await settle(tester);
    expect(find.byType(ManageAppointmentScreen), findsOneWidget);

    await disposeApp(tester);
  });

  testWidgets('asks an account with no profile to finish it', (tester) async {
    backend.profiles.me = testMe(withProfile: false);
    await pumpAppAt(tester, RoutePaths.home, overrides: backend.overrides);

    expect(find.text('Finish setting up your profile'), findsOneWidget);
    await tester.tap(find.text('Complete profile'));
    await settle(tester);
    expect(find.byType(EditProfileScreen), findsOneWidget);

    await disposeApp(tester);
  });

  testWidgets('urgent help goes to real guidance with a way back', (
    tester,
  ) async {
    await pumpAppAt(tester, RoutePaths.home, overrides: backend.overrides);

    await tapText(tester, 'Need urgent help?');
    expect(find.byType(EmergencyGuidanceScreen), findsOneWidget);
    expect(find.text('999'), findsOneWidget);
    expect(find.text('111'), findsOneWidget);
    expect(find.textContaining('not an emergency service'), findsOneWidget);

    await tapBack(tester);
    expect(find.byType(DashboardScreen), findsOneWidget);

    await disposeApp(tester);
  });

  testWidgets('copying an emergency number says so', (tester) async {
    final copied = <String?>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied.add((call.arguments as Map)['text'] as String?);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await pumpAppAt(tester, RoutePaths.emergency, overrides: backend.overrides);

    await tester.tap(find.text('999'));
    await settle(tester);

    expect(copied, ['999']);
    expect(find.text('Copied'), findsOneWidget);

    await disposeApp(tester);
  });
}
