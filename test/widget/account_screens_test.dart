import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifecome_mobile/core/router/route_paths.dart';
import 'package:lifecome_mobile/features/booking/presentation/choose_service_screen.dart';
import 'package:lifecome_mobile/features/emergency/presentation/emergency_guidance_screen.dart';
import 'package:lifecome_mobile/features/health_records/presentation/health_records_screen.dart';
import 'package:lifecome_mobile/features/legal/presentation/privacy_screen.dart';
import 'package:lifecome_mobile/features/legal/presentation/terms_screen.dart';
import 'package:lifecome_mobile/features/membership/presentation/membership_billing_screen.dart';
import 'package:lifecome_mobile/features/membership/presentation/membership_plans_screen.dart';
import 'package:lifecome_mobile/features/membership/presentation/my_benefits_screen.dart';
import 'package:lifecome_mobile/features/messaging/domain/models/message_thread.dart';
import 'package:lifecome_mobile/features/messaging/presentation/new_message_screen.dart';
import 'package:lifecome_mobile/features/payer/presentation/activate_access_screen.dart';
import 'package:lifecome_mobile/features/payer/presentation/hmo_coverage_screen.dart';
import 'package:lifecome_mobile/features/payer/presentation/link_health_plan_screen.dart';
import 'package:lifecome_mobile/features/profile/presentation/patient_profile_screen.dart';
import 'package:lifecome_mobile/features/profile/presentation/privacy_sharing_screen.dart';
import 'package:lifecome_mobile/features/support/presentation/help_centre_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/pump_app.dart';
import '../helpers/test_backend.dart';
import '../helpers/test_fonts.dart';

/// The screens under the Profile tab that used to describe made-up data. Each
/// now shows only what is real, and says plainly when there is nothing yet.
void main() {
  setUpAll(loadManrope);

  late TestBackend backend;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    backend = TestBackend();
  });

  group('Health records', () {
    testWidgets('shows no sample records, only an honest empty state', (
      tester,
    ) async {
      await pumpAppAt(
        tester,
        RoutePaths.healthRecords,
        overrides: backend.overrides,
      );

      expect(find.byType(HealthRecordsScreen), findsOneWidget);
      expect(find.text('Your records will appear here'), findsOneWidget);
      for (final invented in [
        'Sample records',
        'GP visit summary',
        'Uploaded report',
        'Awaiting clinician review',
      ]) {
        expect(find.text(invented), findsNothing);
      }
      // Nothing to search or filter, so nothing pretends to.
      expect(find.byType(TextField), findsNothing);

      await disposeApp(tester);
    });

    testWidgets('has a back button, and links to sharing permissions', (
      tester,
    ) async {
      await pumpAppAt(
        tester,
        RoutePaths.healthRecords,
        overrides: backend.overrides,
      );

      await tapText(tester, 'Manage sharing permissions');
      expect(find.byType(PrivacySharingScreen), findsOneWidget);
      await tapBack(tester);
      expect(find.byType(HealthRecordsScreen), findsOneWidget);

      await tapBack(tester);
      expect(find.byType(HealthRecordsScreen), findsNothing);
      expect(find.byType(PatientProfileScreen), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('uploading says it is not available yet', (tester) async {
      await pumpAppAt(
        tester,
        RoutePaths.healthRecords,
        overrides: backend.overrides,
      );
      await tapText(tester, 'Upload a document');
      expect(find.text('Coming soon'), findsOneWidget);

      await disposeApp(tester);
    });
  });

  group('My benefits', () {
    testWidgets('says no plan is linked rather than claiming one is', (
      tester,
    ) async {
      await pumpAppAt(
        tester,
        RoutePaths.myBenefits,
        overrides: backend.overrides,
      );

      expect(find.byType(MyBenefitsScreen), findsOneWidget);
      expect(find.text('No health plan linked yet'), findsOneWidget);
      for (final invented in [
        'LifeCome Benefits',
        'Connected',
        'Digital GP access',
      ]) {
        expect(find.text(invented), findsNothing);
      }

      await tapText(tester, 'Link a health plan');
      expect(find.byType(LinkHealthPlanScreen), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('shows the plans that have really been verified', (
      tester,
    ) async {
      final router = await pumpAppAt(
        tester,
        RoutePaths.linkHealthPlan,
        overrides: backend.overrides,
      );
      await tester.enterText(find.byType(TextField).first, 'BP-123456');
      await tester.pump();
      await tapText(tester, 'Check my cover');
      expect(find.byType(HmoCoverageScreen), findsOneWidget);

      router.go(RoutePaths.myBenefits);
      await settle(tester);

      expect(find.text('No health plan linked yet'), findsNothing);
      expect(find.text('Bupa'), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);
      // The number is masked: enough to recognise, not to read out.
      expect(find.textContaining('•••• 3456'), findsOneWidget);
      expect(find.textContaining('BP-123456'), findsNothing);

      await tapText(tester, 'See what it covers');
      expect(find.byType(HmoCoverageScreen), findsOneWidget);
      await tapBack(tester);

      await tapText(tester, 'Book covered care');
      expect(find.byType(ChooseServiceScreen), findsOneWidget);
      expect(find.text('Access: Bupa'), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('has a back button', (tester) async {
      await pumpAppAt(
        tester,
        RoutePaths.myBenefits,
        overrides: backend.overrides,
      );
      await tapBack(tester);
      expect(find.byType(MyBenefitsScreen), findsNothing);

      await disposeApp(tester);
    });
  });

  group('Membership and billing', () {
    testWidgets('shows no invented household, members or invitations', (
      tester,
    ) async {
      await pumpAppAt(
        tester,
        RoutePaths.membershipBilling,
        overrides: backend.overrides,
      );

      expect(find.byType(MembershipBillingScreen), findsOneWidget);
      expect(find.text('Nothing to show yet'), findsOneWidget);
      for (final invented in [
        'Adult household plan',
        'Adult member',
        'Invitation pending',
        'Account holder',
      ]) {
        expect(find.text(invented), findsNothing);
      }

      await tapText(tester, 'Explore membership');
      expect(find.byType(MembershipPlansScreen), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('an existing member can send their code', (tester) async {
      await pumpAppAt(
        tester,
        RoutePaths.membershipPlans,
        overrides: backend.overrides,
      );

      await tapText(tester, 'Existing member?');
      expect(find.byType(ActivateAccessScreen), findsOneWidget);
      // It opens on the membership tab.
      expect(find.text('Personal membership access'), findsOneWidget);

      await tapBack(tester);
      expect(find.byType(MembershipPlansScreen), findsOneWidget);
      await tapBack(tester);
      expect(find.byType(MembershipPlansScreen), findsNothing);

      await disposeApp(tester);
    });
  });

  group('Help and support', () {
    testWidgets('has no search that searches nothing', (tester) async {
      await pumpAppAt(
        tester,
        RoutePaths.helpAndSupport,
        overrides: backend.overrides,
      );

      expect(find.byType(HelpCentreScreen), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(find.text('Appointments'), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('a topic starts a message about it', (tester) async {
      await pumpAppAt(
        tester,
        RoutePaths.helpAndSupport,
        overrides: backend.overrides,
      );

      await tapText(tester, 'Payments and refunds');
      expect(find.byType(NewMessageScreen), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'I was charged twice');
      await tester.pump();
      await tapText(tester, 'Send message');
      expect(backend.messaging.lastTopic, MessageTopic.bookingPayments);

      await disposeApp(tester);
    });

    testWidgets('a topic with no matching conversation topic asks to choose', (
      tester,
    ) async {
      await pumpAppAt(
        tester,
        RoutePaths.helpAndSupport,
        overrides: backend.overrides,
      );

      await tapText(tester, 'Account and privacy');
      await tester.enterText(find.byType(TextField), 'Change my email');
      await tester.pump();
      await tapText(tester, 'Send message');
      expect(find.text('Choose what you need help with.'), findsOneWidget);
      expect(backend.messaging.calls, isNot(contains('createThread')));

      await disposeApp(tester);
    });

    testWidgets('urgent help goes to the emergency guidance, not a popup', (
      tester,
    ) async {
      await pumpAppAt(
        tester,
        RoutePaths.helpAndSupport,
        overrides: backend.overrides,
      );

      await tapText(tester, 'View emergency guidance');
      expect(find.byType(EmergencyGuidanceScreen), findsOneWidget);
      expect(find.text('Coming soon'), findsNothing);

      await tapBack(tester);
      expect(find.byType(HelpCentreScreen), findsOneWidget);
      await tapBack(tester);
      expect(find.byType(HelpCentreScreen), findsNothing);

      await disposeApp(tester);
    });
  });

  group('Legal', () {
    testWidgets('the privacy policy has a back button and no invented date', (
      tester,
    ) async {
      await pumpAppAt(
        tester,
        RoutePaths.privacyPolicy,
        overrides: backend.overrides,
      );
      expect(find.byType(PrivacyScreen), findsOneWidget);
      expect(find.textContaining('Last updated'), findsNothing);

      await tapBack(tester);
      expect(find.byType(PrivacyScreen), findsNothing);

      await disposeApp(tester);
    });

    testWidgets('the terms have a back button and no invented date', (
      tester,
    ) async {
      await pumpAppAt(
        tester,
        RoutePaths.termsAndConditions,
        overrides: backend.overrides,
      );
      expect(find.byType(TermsScreen), findsOneWidget);
      expect(find.textContaining('Last updated'), findsNothing);

      await tapBack(tester);
      expect(find.byType(TermsScreen), findsNothing);

      await disposeApp(tester);
    });
  });

  group('Profile', () {
    testWidgets('deleting an account leads to a real message to support', (
      tester,
    ) async {
      await pumpAppAt(tester, RoutePaths.profile, overrides: backend.overrides);

      await tapText(tester, 'Delete my account');
      expect(find.text('Delete your account?'), findsOneWidget);
      expect(
        find.textContaining("isn't available in the app yet"),
        findsOneWidget,
      );

      await tapText(tester, 'Message support');
      expect(find.byType(NewMessageScreen), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('cancelling leaves the account alone', (tester) async {
      await pumpAppAt(tester, RoutePaths.profile, overrides: backend.overrides);

      await tapText(tester, 'Delete my account');
      await tapText(tester, 'Cancel');
      expect(find.byType(NewMessageScreen), findsNothing);
      expect(find.byType(PatientProfileScreen), findsOneWidget);

      await disposeApp(tester);
    });
  });
}
