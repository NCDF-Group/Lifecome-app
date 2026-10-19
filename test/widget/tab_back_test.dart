import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifecome_mobile/core/router/route_paths.dart';
import 'package:lifecome_mobile/features/booking/presentation/my_visits_screen.dart';
import 'package:lifecome_mobile/features/dashboard/presentation/dashboard_screen.dart';
import 'package:lifecome_mobile/features/messaging/presentation/message_threads_screen.dart';
import 'package:lifecome_mobile/features/profile/presentation/patient_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/pump_app.dart';
import '../helpers/test_backend.dart';
import '../helpers/test_fonts.dart';

/// The bottom tabs. Home is where the app starts, so it has nothing to go back
/// to; every other tab has an arrow that returns to it.
void main() {
  setUpAll(loadManrope);

  late TestBackend backend;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    backend = TestBackend();
  });

  final backArrow = find.byIcon(Icons.arrow_back_ios_new);

  for (final (name, path, screen) in [
    ('Visits', RoutePaths.visits, MyVisitsScreen),
    ('Messages', RoutePaths.messages, MessageThreadsScreen),
    ('Profile', RoutePaths.profile, PatientProfileScreen),
  ]) {
    testWidgets('$name has a back arrow that goes Home', (tester) async {
      await pumpAppAt(tester, path, overrides: backend.overrides);
      expect(find.byType(screen), findsOneWidget);
      expect(backArrow, findsOneWidget);

      await tapBack(tester);
      expect(find.byType(screen), findsNothing);
      expect(find.byType(DashboardScreen), findsOneWidget);

      await disposeApp(tester);
    });
  }

  testWidgets('Home has no back arrow, it is where the app starts', (
    tester,
  ) async {
    await pumpAppAt(tester, RoutePaths.home, overrides: backend.overrides);
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(backArrow, findsNothing);

    await disposeApp(tester);
  });
}
