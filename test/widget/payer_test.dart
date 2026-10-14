import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifecome_mobile/core/network/api_exception.dart';
import 'package:lifecome_mobile/core/router/route_paths.dart';
import 'package:lifecome_mobile/features/booking/presentation/booking_confirmation_screen.dart';
import 'package:lifecome_mobile/features/booking/presentation/choose_service_screen.dart';
import 'package:lifecome_mobile/features/booking/presentation/review_booking_screen.dart';
import 'package:lifecome_mobile/features/payer/domain/models/authorisation.dart';
import 'package:lifecome_mobile/features/payer/domain/models/eligibility_status.dart';
import 'package:lifecome_mobile/features/payer/presentation/hmo_coverage_screen.dart';
import 'package:lifecome_mobile/features/payer/presentation/link_health_plan_screen.dart';
import 'package:lifecome_mobile/features/payer/presentation/select_hmo_screen.dart';
import 'package:lifecome_mobile/features/payer/presentation/verify_hmo_membership_screen.dart';
import 'package:lifecome_mobile/features/profile/presentation/edit_profile_screen.dart';
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
      'doc-okoro': [
        testSlot('slot-a', 'doc-okoro', days: 1),
        testSlot('slot-b', 'doc-okoro', days: 2),
      ],
      'doc-patel': [testSlot('slot-d', 'doc-patel', days: 3)],
    };
  });

  Finder field(int index) => find.byType(TextField).at(index);

  Future<void> openVerify(WidgetTester tester, {String plan = 'Bupa'}) async {
    await pumpAppAt(
      tester,
      RoutePaths.payerSelectHmo,
      overrides: backend.overrides,
    );
    await tapText(tester, plan);
  }

  Future<void> verify(WidgetTester tester, String number) async {
    await tester.enterText(field(0), number);
    await tester.pump();
    await tapText(tester, 'Verify membership');
  }

  group('Select your HMO', () {
    testWidgets('lists the plans the backend returns, in its order', (
      tester,
    ) async {
      await pumpAppAt(
        tester,
        RoutePaths.payerSelectHmo,
        overrides: backend.overrides,
      );

      expect(find.byType(SelectHmoScreen), findsOneWidget);
      expect(find.text('Bupa'), findsOneWidget);
      expect(find.text('AXA Health'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Bupa')).dy,
        lessThan(tester.getTopLeft(find.text('AXA Health')).dy),
      );
      // Only the first one is the default.
      expect(find.text('Default'), findsOneWidget);
      // No invented plans.
      expect(find.text('Hygeia HMO'), findsNothing);
      expect(find.text('Leadway Health'), findsNothing);

      await disposeApp(tester);
    });

    testWidgets('search narrows the list, and says when nothing matches', (
      tester,
    ) async {
      await pumpAppAt(
        tester,
        RoutePaths.payerSelectHmo,
        overrides: backend.overrides,
      );

      await tester.enterText(field(0), 'axa');
      await tester.pump();
      expect(find.text('AXA Health'), findsOneWidget);
      expect(find.text('Bupa'), findsNothing);

      await tester.enterText(field(0), 'zzz');
      await tester.pump();
      expect(find.text('No plans match your search'), findsOneWidget);

      await tester.enterText(field(0), 'x' * 101);
      await tester.pump();
      expect(find.text('Search for 100 characters or fewer.'), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('says honestly when no plans are connected', (tester) async {
      backend.payers.payers = [];
      await pumpAppAt(
        tester,
        RoutePaths.payerSelectHmo,
        overrides: backend.overrides,
      );

      expect(find.text('No health plans yet'), findsOneWidget);
      await tapText(tester, 'Pay directly');
      expect(find.byType(ChooseServiceScreen), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('shows an error with a retry when the plans cannot load', (
      tester,
    ) async {
      backend.payers.listFailure = const ApiException(
        ApiException.networkMessage,
      );
      await pumpAppAt(
        tester,
        RoutePaths.payerSelectHmo,
        overrides: backend.overrides,
      );
      expect(find.text("You're offline"), findsOneWidget);

      backend.payers.listFailure = null;
      await tapText(tester, 'Try again');
      expect(find.text('Bupa'), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('has a back button', (tester) async {
      await pumpAppAt(
        tester,
        RoutePaths.payerSelectHmo,
        overrides: backend.overrides,
      );
      await tapBack(tester);
      expect(find.byType(SelectHmoScreen), findsNothing);

      await disposeApp(tester);
    });
  });

  group('Verify your membership', () {
    testWidgets('the number is checked before anything is sent', (
      tester,
    ) async {
      await openVerify(tester);
      expect(find.byType(VerifyHmoMembershipScreen), findsOneWidget);

      await tapText(tester, 'Verify membership');
      expect(find.text('Enter your membership number.'), findsOneWidget);

      await verify(tester, 'ab');
      expect(
        find.text('Membership numbers are 3 to 40 characters.'),
        findsOneWidget,
      );

      await verify(tester, 'AB\$12345');
      expect(
        find.text('Use letters, numbers, spaces and dashes only.'),
        findsOneWidget,
      );
      expect(backend.payers.calls, isNot(contains('verifyMembership')));

      await disposeApp(tester);
    });

    testWidgets('checks the number with the plan, then shows its cover', (
      tester,
    ) async {
      backend.payers.coverage = {'FOLLOW_UP': EligibilityStatus.coPay};
      backend.payers.coPay = {'FOLLOW_UP': 1500};
      await openVerify(tester);
      await verify(tester, '  bp-123456  ');

      expect(backend.payers.lastPayerCode, 'BUPA');
      // Trimmed, and sent with an idempotency key.
      expect(backend.payers.lastMemberId, 'bp-123456');
      expect(backend.payers.lastVerifyKey, isNotEmpty);

      expect(find.byType(HmoCoverageScreen), findsOneWidget);
      expect(find.text('Bupa'), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);
      expect(find.text('Gold'), findsOneWidget);
      expect(find.text('GP Consultation'), findsOneWidget);
      expect(find.text('Covered'), findsOneWidget);
      expect(find.text('Follow-up Visit'), findsOneWidget);
      expect(find.text('Co-pay £15.00'), findsOneWidget);

      // Back returns to the number, then to the list of plans.
      await tapBack(tester);
      expect(find.byType(VerifyHmoMembershipScreen), findsOneWidget);
      await tapBack(tester);
      expect(find.byType(SelectHmoScreen), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('a number the plan does not know is explained in words', (
      tester,
    ) async {
      backend.payers.verifyFailure = const ApiException(
        'Your membership could not be verified (not_found).',
        code: 'MEMBERSHIP_NOT_VERIFIED',
        statusCode: 422,
      );
      await openVerify(tester);
      await verify(tester, 'BP-000000');

      expect(
        find.text(
          "We couldn't find that membership number with Bupa. Check it "
          'against your card and try again.',
        ),
        findsOneWidget,
      );
      // The raw reason in brackets never reaches the screen.
      expect(find.textContaining('(not_found)'), findsNothing);
      expect(find.byType(HmoCoverageScreen), findsNothing);

      await disposeApp(tester);
    });

    testWidgets('each reason the plan gives has its own wording', (
      tester,
    ) async {
      await openVerify(tester);

      for (final (reason, expected) in [
        ('mismatch', "Those details don't match Bupa's records."),
        (
          'manual_review',
          "Bupa needs to check this one by hand. Message the care team and "
              "we'll help.",
        ),
        (
          'payer_unavailable',
          "Bupa isn't responding right now. Please try again in a few "
              'minutes.',
        ),
      ]) {
        backend.payers.verifyFailure = ApiException(
          'Your membership could not be verified ($reason).',
          code: 'MEMBERSHIP_NOT_VERIFIED',
          statusCode: 422,
        );
        await verify(tester, 'BP-123456');
        expect(find.text(expected), findsOneWidget);
      }

      await disposeApp(tester);
    });

    testWidgets(
      'a retry of the same number reuses its key, a new one does not',
      (tester) async {
        backend.payers.verifyFailure = const ApiException(
          ApiException.networkMessage,
        );
        await openVerify(tester);

        await verify(tester, 'BP-123456');
        final first = backend.payers.lastVerifyKey;
        expect(find.text("You're offline"), findsOneWidget);
        await tapText(tester, 'OK');

        await verify(tester, 'BP-123456');
        expect(backend.payers.lastVerifyKey, first);
        await tapText(tester, 'OK');

        await verify(tester, 'BP-654321');
        expect(backend.payers.lastVerifyKey, isNot(first));
        await tapText(tester, 'OK');

        await disposeApp(tester);
      },
    );

    testWidgets('a person without a profile is asked to finish it', (
      tester,
    ) async {
      backend.payers.verifyFailure = const ApiException(
        'Complete your profile before continuing.',
        code: 'PROFILE_REQUIRED',
        statusCode: 403,
      );
      await openVerify(tester);
      await verify(tester, 'BP-123456');

      expect(find.text('Finish your profile first'), findsOneWidget);
      await tapText(tester, 'Complete profile');
      expect(find.byType(EditProfileScreen), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('opened without its plan, it goes back to the list', (
      tester,
    ) async {
      await pumpAppAt(
        tester,
        RoutePaths.payerVerifyMembership,
        overrides: backend.overrides,
      );
      expect(find.byType(VerifyHmoMembershipScreen), findsNothing);
      expect(find.byType(SelectHmoScreen), findsOneWidget);

      await disposeApp(tester);
    });
  });

  group('Link your health plan', () {
    testWidgets('starts on the first plan and validates the number', (
      tester,
    ) async {
      await pumpAppAt(
        tester,
        RoutePaths.linkHealthPlan,
        overrides: backend.overrides,
      );

      expect(find.byType(LinkHealthPlanScreen), findsOneWidget);
      expect(find.text('Bupa'), findsOneWidget);

      await tapText(tester, 'Check my cover');
      expect(find.text('Enter your membership number.'), findsOneWidget);
      expect(backend.payers.calls, isNot(contains('verifyMembership')));

      await tester.enterText(field(0), 'BP-123456');
      await tester.pump();
      await tapText(tester, 'Check my cover');
      expect(backend.payers.lastPayerCode, 'BUPA');
      expect(find.byType(HmoCoverageScreen), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('says honestly when no plans are connected', (tester) async {
      backend.payers.payers = [];
      await pumpAppAt(
        tester,
        RoutePaths.linkHealthPlan,
        overrides: backend.overrides,
      );
      expect(find.text('No health plans yet'), findsOneWidget);
      expect(find.text('Check my cover'), findsNothing);

      await disposeApp(tester);
    });

    testWidgets('has a back button', (tester) async {
      await pumpAppAt(
        tester,
        RoutePaths.linkHealthPlan,
        overrides: backend.overrides,
      );
      await tapBack(tester);
      expect(find.byType(LinkHealthPlanScreen), findsNothing);

      await disposeApp(tester);
    });
  });

  group('booking with a health plan', () {
    Future<void> toCoverage(WidgetTester tester) async {
      await openVerify(tester);
      await verify(tester, 'BP-123456');
    }

    testWidgets('each service shows what the plan says about it', (
      tester,
    ) async {
      backend.payers.coverage = {'FOLLOW_UP': EligibilityStatus.excluded};
      await toCoverage(tester);
      await tapText(tester, 'Book covered care');

      expect(find.byType(ChooseServiceScreen), findsOneWidget);
      expect(find.text('Access: Bupa'), findsOneWidget);
      expect(find.text('Covered'), findsOneWidget);
      expect(find.text('Not covered'), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('a service the plan will not pay for cannot be continued', (
      tester,
    ) async {
      backend.payers.coverage = {'FOLLOW_UP': EligibilityStatus.excluded};
      await toCoverage(tester);
      await tapText(tester, 'Book covered care');

      await tapText(tester, 'Follow-up Visit');
      expect(find.text("Bupa won't pay for this"), findsOneWidget);
      final continueButton = find.widgetWithText(FilledButton, 'Continue');
      expect(tester.widget<FilledButton>(continueButton).onPressed, isNull);

      // Paying for it directly is offered instead.
      await tapText(tester, 'Pay for it myself instead');
      expect(find.byType(ChooseServiceScreen), findsWidgets);
      expect(find.text('Access: Bupa'), findsNothing);

      await disposeApp(tester);
    });

    /// Walks from the cover screen to the review screen.
    Future<void> toReview(WidgetTester tester) async {
      await toCoverage(tester);
      await tapText(tester, 'Book covered care');
      await tapText(tester, 'Continue');
      await tester.enterText(field(0), 'Leeds');
      await tester.enterText(field(1), 'LS1 4AB');
      await tapText(tester, 'Check availability');
      await tester.tap(
        find
            .text(ukClock(backend.booking.availability['doc-okoro']!.first))
            .first,
      );
      await settle(tester);
      await tester.enterText(field(0), 'A cough that will not go away');
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await tapText(tester, 'Continue');
      expect(find.byType(ReviewBookingScreen), findsOneWidget);
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
    }

    testWidgets('a covered visit is booked against the plan, not paid for', (
      tester,
    ) async {
      await toReview(tester);
      expect(find.text('Funding'), findsOneWidget);
      expect(find.text('Bupa'), findsOneWidget);
      expect(find.text('Covered'), findsOneWidget);

      await tapText(tester, 'Confirm booking');

      expect(
        backend.booking.calls,
        containsAllInOrder(['createAppointment', 'confirmAppointment']),
      );
      // The plan is asked again at the moment of booking.
      expect(
        backend.payers.calls.where(
          (c) => c == 'checkEligibility:GP_CONSULTATION',
        ),
        hasLength(greaterThanOrEqualTo(2)),
      );
      // No payment is started for a plan-funded visit.
      expect(backend.booking.calls, isNot(contains('createPaymentIntent')));
      expect(
        backend.booking.lastRequest!.fundingRoute.apiValue,
        'lifecome_benefits',
      );

      expect(find.byType(BookingConfirmationScreen), findsOneWidget);
      expect(find.text('Appointment confirmed'), findsOneWidget);
      expect(find.text('Covered by Bupa'), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('a visit that needs approval asks the plan and waits', (
      tester,
    ) async {
      backend.payers.coverage = {
        'GP_CONSULTATION': EligibilityStatus.preAuthorisationRequired,
      };
      await toReview(tester);
      expect(find.text('Needs authorisation'), findsOneWidget);

      await tapText(tester, 'Confirm booking');

      expect(backend.payers.calls, contains('requestAuthorisation'));
      expect(backend.payers.lastAuthorisationKey, isNotEmpty);
      // It is not confirmed while the plan has not said yes.
      expect(backend.booking.calls, isNot(contains('confirmAppointment')));
      expect(backend.booking.calls, isNot(contains('createPaymentIntent')));

      expect(find.byType(BookingConfirmationScreen), findsOneWidget);
      expect(find.text('Waiting for confirmation'), findsOneWidget);
      expect(find.text('Waiting for Bupa to approve'), findsOneWidget);
      expect(find.text('Your time is being held'), findsOneWidget);
      expect(find.text('Appointment confirmed'), findsNothing);

      await disposeApp(tester);
    });

    testWidgets('an approval that comes straight back confirms the visit', (
      tester,
    ) async {
      backend.payers.coverage = {
        'GP_CONSULTATION': EligibilityStatus.preAuthorisationRequired,
      };
      backend.payers.authorisationStatus = AuthorisationStatus.approved;
      await toReview(tester);
      await tapText(tester, 'Confirm booking');

      expect(backend.booking.calls, contains('confirmAppointment'));
      expect(find.text('Appointment confirmed'), findsOneWidget);
      expect(find.text('Approved by Bupa'), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('cover that has gone by booking time stops it with a reason', (
      tester,
    ) async {
      await toReview(tester);
      // Between choosing the service and confirming, the plan stopped
      // covering it.
      backend.payers.coverage = {
        'GP_CONSULTATION': EligibilityStatus.benefitLimitReached,
      };
      await tapText(tester, 'Confirm booking');

      expect(
        find.text("You've used all of your Bupa benefit for this service."),
        findsOneWidget,
      );
      // Nothing was booked and no time is held.
      expect(backend.booking.calls, isNot(contains('createAppointment')));
      expect(find.byType(BookingConfirmationScreen), findsNothing);

      await disposeApp(tester);
    });
  });
}
