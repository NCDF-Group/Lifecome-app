import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:lifecome_mobile/core/network/api_exception.dart';
import 'package:lifecome_mobile/core/providers/core_providers.dart';
import 'package:lifecome_mobile/core/router/route_paths.dart';
import 'package:lifecome_mobile/core/storage/secure_storage.dart';
import 'package:lifecome_mobile/features/dashboard/presentation/dashboard_screen.dart';
import 'package:lifecome_mobile/features/profile/application/profile_controller.dart';
import 'package:lifecome_mobile/features/profile/presentation/edit_profile_screen.dart';
import 'package:lifecome_mobile/features/profile/presentation/patient_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_auth_repository.dart';
import '../helpers/fake_profile_repository.dart';
import '../helpers/pump_app.dart';
import '../helpers/test_fonts.dart';

void main() {
  setUpAll(loadManrope);

  late FakeProfileRepository profiles;
  late List<Override> overrides;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    profiles = FakeProfileRepository();
    overrides = [
      authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      tokenStoreProvider.overrideWithValue(MemoryTokenStore()),
      profileRepositoryProvider.overrideWithValue(profiles),
    ];
  });

  Finder field(int index) => find.byType(TextField).at(index);

  group('profile tab', () {
    testWidgets('shows the real name, email and initials — nothing invented', (
      tester,
    ) async {
      await pumpAppAt(tester, RoutePaths.profile, overrides: overrides);

      expect(find.byType(PatientProfileScreen), findsOneWidget);
      expect(find.text('Alex Morgan'), findsOneWidget);
      expect(find.text('alex.morgan@example.com'), findsOneWidget);
      // No photo has been uploaded, so the avatar is the real initials.
      expect(find.text('AM'), findsOneWidget);
      expect(
        find.textContaining('Finish setting up your profile'),
        findsNothing,
      );

      await disposeApp(tester);
    });

    testWidgets('nudges an account with no profile to finish it', (
      tester,
    ) async {
      profiles.me = testMe(withProfile: false);
      await pumpAppAt(tester, RoutePaths.profile, overrides: overrides);

      expect(
        find.textContaining('Finish setting up your profile'),
        findsOneWidget,
      );
      await tester.tap(find.textContaining('Finish setting up your profile'));
      await settle(tester);
      expect(find.byType(EditProfileScreen), findsOneWidget);
      expect(find.text('Complete your profile'), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('says so, with a retry, when the profile cannot be loaded', (
      tester,
    ) async {
      profiles.loadFailure = const ApiException(ApiException.networkMessage);
      await pumpAppAt(tester, RoutePaths.profile, overrides: overrides);

      expect(find.text(ApiException.networkMessage), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      // The rest of the tab is still usable.
      expect(find.text('Sign out'), findsOneWidget);

      profiles.loadFailure = null;
      await tapText(tester, 'Try again');
      expect(find.text('Alex Morgan'), findsOneWidget);

      await disposeApp(tester);
    });
  });

  group('edit profile', () {
    testWidgets('is filled in from the backend and has a back button', (
      tester,
    ) async {
      await pumpAppAt(tester, RoutePaths.profile, overrides: overrides);
      await tapText(tester, 'Personal details');
      expect(find.byType(EditProfileScreen), findsOneWidget);

      expect(find.text('Alex'), findsOneWidget);
      expect(find.text('Morgan'), findsOneWidget);
      expect(find.text('20 / 05 / 1990'), findsOneWidget);
      expect(find.text('Leeds'), findsOneWidget);
      expect(find.text('West Yorkshire'), findsOneWidget);
      // Fields the backend has nowhere to keep are not offered.
      expect(find.text('Postcode'), findsNothing);
      expect(find.textContaining('GP practice'), findsNothing);

      await tapBack(tester);
      expect(find.byType(EditProfileScreen), findsNothing);
      expect(find.byType(PatientProfileScreen), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('back works even when nothing is behind it', (tester) async {
      await pumpAppAt(tester, RoutePaths.editProfile, overrides: overrides);
      expect(find.byType(EditProfileScreen), findsOneWidget);

      await tapBack(tester);
      expect(find.byType(EditProfileScreen), findsNothing);
      expect(find.byType(PatientProfileScreen), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('will not save a missing or invalid name', (tester) async {
      await pumpAppAt(tester, RoutePaths.editProfile, overrides: overrides);

      await tester.enterText(field(0), '');
      await tester.enterText(field(1), 'R2D2');
      await tapText(tester, 'Save profile');

      expect(find.text('Enter your first name.'), findsOneWidget);
      expect(
        find.text(
          'Use letters only in your last name (spaces, hyphens and apostrophes are fine).',
        ),
        findsOneWidget,
      );
      expect(profiles.calls.where((c) => c.endsWith('Profile')), isEmpty);

      // The message clears the moment the field is fixed.
      await tester.enterText(field(0), 'Alexandra');
      await tester.pump();
      expect(find.text('Enter your first name.'), findsNothing);

      await disposeApp(tester);
    });

    testWidgets('saves the change and confirms it', (tester) async {
      await pumpAppAt(tester, RoutePaths.profile, overrides: overrides);
      await tapText(tester, 'Personal details');

      await tester.enterText(field(0), 'Alexandra');
      await tester.enterText(field(3), 'York');
      await tapText(tester, 'Save profile');

      expect(profiles.calls, contains('updateProfile'));
      expect(profiles.lastInput?.firstName, 'Alexandra');
      expect(profiles.lastInput?.lastName, 'Morgan');
      expect(profiles.lastInput?.city, 'York');
      expect(profiles.lastInput?.dateOfBirth, DateTime(1990, 5, 20));
      expect(find.text('Profile updated'), findsOneWidget);

      // Dismissing the confirmation returns to the profile tab, which now
      // shows the new name.
      await tapText(tester, 'Done');
      expect(find.byType(EditProfileScreen), findsNothing);
      expect(find.text('Alexandra Morgan'), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('clearing a field that was set sends an empty value', (
      tester,
    ) async {
      await pumpAppAt(tester, RoutePaths.editProfile, overrides: overrides);

      await tester.enterText(field(4), '');
      await tapText(tester, 'Save profile');

      expect(profiles.lastInput?.state, '');
      expect(profiles.lastInput?.city, 'Leeds');

      await disposeApp(tester);
    });

    testWidgets("shows the backend's complaint under the right field", (
      tester,
    ) async {
      profiles.failure = const ApiException(
        'Check the details you entered.',
        code: 'VALIDATION_FAILED',
        statusCode: 400,
        fieldErrors: {'city': 'That town or city is not recognised.'},
      );
      await pumpAppAt(tester, RoutePaths.editProfile, overrides: overrides);

      await tapText(tester, 'Save profile');

      expect(find.text('That town or city is not recognised.'), findsOneWidget);
      expect(find.byType(EditProfileScreen), findsOneWidget);

      await disposeApp(tester);
    });
  });

  group('complete profile (after sign-up)', () {
    testWidgets('needs a date of birth and then continues to Home', (
      tester,
    ) async {
      profiles.me = testMe(withProfile: false);
      await pumpAppAt(tester, RoutePaths.completeProfile, overrides: overrides);

      expect(find.text('Complete your profile'), findsOneWidget);
      await tester.enterText(field(0), 'Alex');
      await tester.enterText(field(1), 'Morgan');
      await tapText(tester, 'Save and continue');
      expect(find.text('Enter your date of birth.'), findsOneWidget);
      expect(profiles.calls.where((c) => c.endsWith('Profile')), isEmpty);

      // Choose a date from the calendar (it opens on a date 30 years ago).
      await tester.tap(field(2));
      await settle(tester);
      await tester.tap(find.text('OK'));
      await settle(tester);
      expect(find.text('Enter your date of birth.'), findsNothing);

      await tapText(tester, 'Save and continue');
      expect(profiles.calls, contains('saveProfile'));
      expect(find.byType(DashboardScreen), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('can be put off until later', (tester) async {
      profiles.me = testMe(withProfile: false);
      await pumpAppAt(tester, RoutePaths.completeProfile, overrides: overrides);

      await tapText(tester, 'Do this later');
      expect(find.byType(EditProfileScreen), findsNothing);
      expect(find.byType(DashboardScreen), findsOneWidget);

      await disposeApp(tester);
    });
  });
}
