import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifecome_mobile/core/network/api_exception.dart';
import 'package:lifecome_mobile/core/router/route_paths.dart';
import 'package:lifecome_mobile/features/booking/domain/models/appointment.dart';
import 'package:lifecome_mobile/features/booking/domain/models/booking_status.dart';
import 'package:lifecome_mobile/features/booking/domain/models/consultation_mode.dart';
import 'package:lifecome_mobile/features/booking/presentation/appointment_check_screen.dart';
import 'package:lifecome_mobile/features/booking/presentation/before_your_visit_screen.dart';
import 'package:lifecome_mobile/features/booking/presentation/booking_confirmation_screen.dart';
import 'package:lifecome_mobile/features/booking/presentation/booking_location_screen.dart';
import 'package:lifecome_mobile/features/booking/presentation/choose_access_screen.dart';
import 'package:lifecome_mobile/features/booking/presentation/choose_appointment_time_screen.dart';
import 'package:lifecome_mobile/features/booking/presentation/choose_service_screen.dart';
import 'package:lifecome_mobile/features/booking/presentation/manage_appointment_screen.dart';
import 'package:lifecome_mobile/features/booking/presentation/my_visits_screen.dart';
import 'package:lifecome_mobile/features/booking/presentation/review_booking_screen.dart';
import 'package:lifecome_mobile/features/doctors/presentation/doctor_profile_screen.dart';
import 'package:lifecome_mobile/features/doctors/presentation/find_a_doctor_screen.dart';
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
        testSlot('slot-b', 'doc-okoro', days: 1, hourUtc: 11),
        testSlot('slot-c', 'doc-okoro', days: 2),
      ],
      'doc-patel': [testSlot('slot-d', 'doc-patel', days: 3)],
    };
  });

  Finder field(int index) => find.byType(TextField).at(index);

  /// Walks Pay per visit → service → location → clinician → first time.
  Future<void> walkToVisitDetails(WidgetTester tester) async {
    await pumpAppAt(tester, RoutePaths.visits, overrides: backend.overrides);
    await tapText(tester, 'Book a consultation');
    await tapText(tester, 'Pay per visit');
    await tapText(tester, 'Continue'); // first service is preselected
    await tester.enterText(field(0), 'Leeds');
    await tester.enterText(field(1), 'ls1 4ab');
    await tapText(tester, 'Check availability');
    // Dr Okoro's first free time.
    final firstClock = ukClock(
      backend.booking.availability['doc-okoro']!.first,
    );
    await tester.tap(find.text(firstClock).first);
    await settle(tester);
  }

  group('My visits', () {
    testWidgets('says honestly that there are none yet', (tester) async {
      await pumpAppAt(tester, RoutePaths.visits, overrides: backend.overrides);

      expect(find.byType(MyVisitsScreen), findsOneWidget);
      expect(find.text('No visits yet'), findsOneWidget);
      expect(find.text('Book a consultation'), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('lists real upcoming and past appointments', (tester) async {
      backend.booking.appointments = [
        testAppointment(id: 'upcoming-1', serviceName: 'GP Consultation'),
        testAppointment(
          id: 'past-1',
          serviceName: 'Follow-up Visit',
          startsAt: DateTime.now().toUtc().subtract(const Duration(days: 9)),
        ),
        testAppointment(
          id: 'cancelled-1',
          serviceName: 'Results Review',
          status: BookingStatus.cancelled,
        ),
      ];
      await pumpAppAt(tester, RoutePaths.visits, overrides: backend.overrides);

      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Past'), findsOneWidget);
      expect(find.text('GP Consultation'), findsOneWidget);
      expect(find.text('Follow-up Visit'), findsOneWidget);
      expect(find.text('Cancelled'), findsOneWidget);
      expect(find.text('No visits yet'), findsNothing);

      await disposeApp(tester);
    });

    testWidgets('shows an error with a retry when the list cannot load', (
      tester,
    ) async {
      backend.booking.listFailure = const ApiException(
        ApiException.networkMessage,
      );
      await pumpAppAt(tester, RoutePaths.visits, overrides: backend.overrides);

      expect(find.text("You're offline"), findsOneWidget);

      backend.booking.listFailure = null;
      backend.booking.appointments = [testAppointment()];
      await tapText(tester, 'Try again');
      expect(find.text('GP Consultation'), findsOneWidget);

      await disposeApp(tester);
    });
  });

  group('booking', () {
    testWidgets('the services and prices come from the backend', (
      tester,
    ) async {
      await pumpAppAt(tester, RoutePaths.visits, overrides: backend.overrides);
      await tapText(tester, 'Book a consultation');
      expect(find.byType(ChooseAccessScreen), findsOneWidget);
      await tapText(tester, 'Pay per visit');

      expect(find.byType(ChooseServiceScreen), findsOneWidget);
      expect(find.text('GP Consultation'), findsOneWidget);
      expect(find.textContaining('£60.00'), findsOneWidget);
      expect(find.text('Follow-up Visit'), findsOneWidget);
      expect(find.textContaining('£45.00'), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('every step has a working back button', (tester) async {
      await pumpAppAt(tester, RoutePaths.visits, overrides: backend.overrides);
      await tapText(tester, 'Book a consultation');
      await tapText(tester, 'Pay per visit');
      await tapText(tester, 'Continue');
      expect(find.byType(BookingLocationScreen), findsOneWidget);

      await tapBack(tester);
      expect(find.byType(ChooseServiceScreen), findsOneWidget);
      await tapBack(tester);
      expect(find.byType(ChooseAccessScreen), findsOneWidget);
      await tapBack(tester);
      expect(find.byType(MyVisitsScreen), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('the location needs a town and a valid postcode', (
      tester,
    ) async {
      await pumpAppAt(tester, RoutePaths.visits, overrides: backend.overrides);
      await tapText(tester, 'Book a consultation');
      await tapText(tester, 'Pay per visit');
      await tapText(tester, 'Continue');

      await tester.enterText(field(0), '');
      await tester.enterText(field(1), '12345');
      await tapText(tester, 'Check availability');
      expect(find.text('Enter your town or city.'), findsOneWidget);
      expect(
        find.text('Enter a valid UK postcode, like SW1A 1AA.'),
        findsOneWidget,
      );
      expect(find.byType(BookingLocationScreen), findsOneWidget);

      await tester.enterText(field(0), 'Leeds');
      await tester.enterText(field(1), 'LS1 4AB');
      await tapText(tester, 'Check availability');
      expect(find.byType(FindADoctorScreen), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('lists the real clinicians with their real free times', (
      tester,
    ) async {
      await pumpAppAt(tester, RoutePaths.visits, overrides: backend.overrides);
      await tapText(tester, 'Book a consultation');
      await tapText(tester, 'Pay per visit');
      await tapText(tester, 'Continue');
      await tester.enterText(field(0), 'Leeds');
      await tester.enterText(field(1), 'LS1 4AB');
      await tapText(tester, 'Check availability');

      expect(find.text('Dr Sam Okoro'), findsOneWidget);
      // Dr Patel offers video too.
      expect(find.text('Dr Priya Patel'), findsOneWidget);
      // Avatars are initials, never a stock face.
      expect(find.text('SO'), findsOneWidget);
      expect(find.text('PP'), findsOneWidget);
      expect(find.text('Sample availability'), findsNothing);
      expect(
        find.text(ukClock(backend.booking.availability['doc-okoro']!.first)),
        findsWidgets,
      );

      // A phone appointment hides the video-only clinician? Both offer video;
      // only Dr Okoro offers telephone.
      await tapText(tester, 'Telephone');
      expect(find.text('Dr Sam Okoro'), findsOneWidget);
      expect(find.text('Dr Priya Patel'), findsNothing);

      await disposeApp(tester);
    });

    testWidgets('the clinician profile shows only what the directory holds', (
      tester,
    ) async {
      await pumpAppAt(tester, RoutePaths.visits, overrides: backend.overrides);
      await tapText(tester, 'Book a consultation');
      await tapText(tester, 'Pay per visit');
      await tapText(tester, 'Continue');
      await tester.enterText(field(0), 'Leeds');
      await tester.enterText(field(1), 'LS1 4AB');
      await tapText(tester, 'Check availability');
      await tester.tap(find.text('Dr Sam Okoro').first);
      await settle(tester);

      expect(find.byType(DoctorProfileScreen), findsOneWidget);
      expect(find.text('Dr Sam Okoro'), findsOneWidget);
      expect(find.text('English, Igbo'), findsOneWidget);
      expect(find.text('Professional registration'), findsNothing);

      await tapText(tester, 'Choose a time');
      expect(find.byType(ChooseAppointmentTimeScreen), findsOneWidget);
      expect(find.textContaining('UK time ('), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('the visit details form validates before it goes on', (
      tester,
    ) async {
      await walkToVisitDetails(tester);
      expect(find.byType(BeforeYourVisitScreen), findsOneWidget);

      await tapText(tester, 'Continue');
      expect(
        find.text('Enter what you would like to discuss.'),
        findsOneWidget,
      );
      expect(find.text('Please confirm to continue.'), findsOneWidget);
      expect(find.byType(BeforeYourVisitScreen), findsOneWidget);

      await tester.enterText(field(0), 'too short');
      await tapText(tester, 'Continue');
      expect(
        find.text('Add a little more detail (at least 10 characters).'),
        findsOneWidget,
      );

      await disposeApp(tester);
    });

    testWidgets('a bad phone number is rejected, a landline accepted', (
      tester,
    ) async {
      await walkToVisitDetails(tester);
      await tester.enterText(field(0), 'A cough that will not go away');
      await tester.enterText(field(3), '12345');
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await tapText(tester, 'Continue');
      expect(
        find.textContaining('Enter a valid UK phone number'),
        findsOneWidget,
      );
      expect(find.byType(ReviewBookingScreen), findsNothing);

      await tester.enterText(field(3), '020 7946 0958');
      await tapText(tester, 'Continue');
      expect(find.byType(ReviewBookingScreen), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('books for real and shows it confirmed', (tester) async {
      await walkToVisitDetails(tester);
      await tester.enterText(field(0), 'A cough that will not go away');
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await tapText(tester, 'Continue');

      expect(find.byType(ReviewBookingScreen), findsOneWidget);
      expect(find.text('Dr Sam Okoro'), findsOneWidget);
      expect(find.text('Pay per visit'), findsOneWidget);
      expect(find.text('£60.00'), findsOneWidget);

      // Not confirmed until the person agrees.
      await tapText(tester, 'Confirm booking');
      expect(find.text('Please confirm to continue.'), findsOneWidget);
      expect(backend.booking.calls, isNot(contains('createAppointment')));

      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await tapText(tester, 'Confirm booking');

      expect(
        backend.booking.calls,
        containsAllInOrder([
          'createAppointment',
          'createPaymentIntent',
          'confirmAppointment',
        ]),
      );
      final request = backend.booking.lastRequest!;
      expect(request.providerId, 'doc-okoro');
      expect(request.clinicalServiceId, 'svc-gp');
      expect(request.availabilitySlotId, 'slot-a');
      expect(request.mode, ConsultationMode.video);
      expect(request.fundingRoute.apiValue, 'pay_per_visit');
      expect(request.presentingConcern, 'A cough that will not go away');
      expect(request.intake?.understoodRemoteLimits, isTrue);
      expect(request.intake?.patientLocation, 'Leeds, LS1 4AB');
      expect(backend.booking.lastCreateKey, isNotNull);
      expect(backend.booking.lastPaymentKey, isNotNull);

      expect(find.byType(BookingConfirmationScreen), findsOneWidget);
      expect(find.text("You're booked in"), findsOneWidget);
      expect(find.text('Dr Sam Okoro'), findsOneWidget);
      expect(find.text('LCL-BBBBBBBB'), findsOneWidget);
      // No payment has been seen to succeed, so none is claimed.
      expect(find.textContaining('Payment received'), findsNothing);

      // Back from the confirmation lands on My Visits, which lists it.
      await tapBack(tester);
      expect(find.byType(MyVisitsScreen), findsOneWidget);
      expect(find.text('GP Consultation'), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('a booking that is still waiting for payment says so', (
      tester,
    ) async {
      backend.booking.confirmFailure = const ApiException(
        'This booking is confirmed once payment or authorisation completes.',
        code: 'PAYMENT_REQUIRED',
        statusCode: 403,
      );
      await walkToVisitDetails(tester);
      await tester.enterText(field(0), 'A cough that will not go away');
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await tapText(tester, 'Continue');
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await tapText(tester, 'Confirm booking');

      expect(find.byType(BookingConfirmationScreen), findsOneWidget);
      expect(find.text('Waiting for confirmation'), findsOneWidget);
      expect(find.text('Your time is being held'), findsOneWidget);
      expect(find.text("You're booked in"), findsNothing);
      expect(find.textContaining('awaiting payment'), findsOneWidget);

      // The payment comes through on the server; checking brings it in.
      backend.booking.confirmOnServer('bbbbbbbb-1111-2222-3333-444444444444');
      await tapText(tester, 'Check status');
      expect(find.text("You're booked in"), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('a time that was just taken sends the person back to pick', (
      tester,
    ) async {
      backend.booking.createFailure = const ApiException(
        'This time is no longer available. Please choose another.',
        code: 'SLOT_UNAVAILABLE',
        statusCode: 409,
      );
      await walkToVisitDetails(tester);
      await tester.enterText(field(0), 'A cough that will not go away');
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await tapText(tester, 'Continue');
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await tapText(tester, 'Confirm booking');

      expect(
        find.text('This time is no longer available. Please choose another.'),
        findsOneWidget,
      );
      await tapText(tester, 'Try again');
      expect(find.byType(ChooseAppointmentTimeScreen), findsOneWidget);
      expect(find.byType(ReviewBookingScreen), findsNothing);

      await disposeApp(tester);
    });
  });

  group('managing a booking', () {
    testWidgets('shows the real appointment and cancels it for real', (
      tester,
    ) async {
      backend.booking.appointments = [testAppointment(id: 'apt-1')];
      await pumpAppAt(tester, RoutePaths.visits, overrides: backend.overrides);
      await tapText(tester, 'GP Consultation');

      expect(find.byType(ManageAppointmentScreen), findsOneWidget);
      expect(find.text('with Dr Sam Okoro'), findsOneWidget);
      expect(find.text('Confirmed'), findsOneWidget);

      await tapText(tester, 'Cancel appointment');
      // The confirmation popup repeats the title as its button.
      await tester.tap(find.text('Cancel appointment').last);
      await settle(tester);

      expect(backend.booking.calls, contains('cancelAppointment'));
      expect(find.text('Appointment cancelled'), findsOneWidget);
      await tapText(tester, 'Done');
      expect(find.byType(MyVisitsScreen), findsOneWidget);
      expect(find.text('Cancelled'), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('prepare-for-your-visit shows what the clinician was told', (
      tester,
    ) async {
      final appointment = testAppointment(
        intake: const AppointmentIntake(
          reason: 'A cough that will not go away\n\nHow long: a few days.',
          medicinesAndAllergies: 'Penicillin allergy',
        ),
      );
      await pumpAppAt(
        tester,
        RoutePaths.appointmentCheck,
        overrides: backend.overrides,
        extra: appointment,
      );

      expect(find.byType(AppointmentCheckScreen), findsOneWidget);
      expect(find.text('What your clinician has been told'), findsOneWidget);
      expect(
        find.textContaining('A cough that will not go away'),
        findsOneWidget,
      );
      expect(find.text('Penicillin allergy'), findsOneWidget);
      expect(find.text('Before you join'), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('a screen opened without its appointment goes somewhere safe', (
      tester,
    ) async {
      await pumpAppAt(
        tester,
        RoutePaths.manageAppointment,
        overrides: backend.overrides,
      );
      expect(find.byType(ManageAppointmentScreen), findsNothing);
      expect(find.byType(MyVisitsScreen), findsOneWidget);

      await disposeApp(tester);
    });
  });
}
