import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifecome_mobile/core/router/route_paths.dart';
import 'package:lifecome_mobile/features/care_plan/presentation/care_plan_screen.dart';
import 'package:lifecome_mobile/features/consultation/domain/models/consultation_status.dart';
import 'package:lifecome_mobile/features/consultation/presentation/consultation_call_screen.dart';
import 'package:lifecome_mobile/features/consultation/presentation/waiting_room_screen.dart';
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

  final appointment = testAppointment(
    id: 'cccccccc-1111-2222-3333-444444444444',
  );

  Future<void> openWaitingRoom(WidgetTester tester) => pumpAppAt(
    tester,
    RoutePaths.consultationWaitingRoom,
    overrides: backend.overrides,
    extra: appointment,
  );

  group('waiting room', () {
    testWidgets('checks in step by step and then waits', (tester) async {
      await openWaitingRoom(tester);

      expect(find.byType(WaitingRoomScreen), findsOneWidget);
      expect(find.text('Ready to check in?'), findsOneWidget);
      // Nothing about cameras and microphones is claimed to be ready.
      expect(find.text('Camera ready'), findsNothing);

      await tapText(tester, 'Check in');

      expect(
        backend.consultation.calls,
        containsAllInOrder([
          'transition:check_in_open',
          'transition:device_check',
          'transition:waiting',
        ]),
      );
      expect(find.text('Waiting for your clinician'), findsOneWidget);
      expect(find.text('Check in'), findsNothing);

      await disposeApp(tester);
    });

    testWidgets('lets the person in once the clinician has started', (
      tester,
    ) async {
      backend.consultation.status = ConsultationStatus.waiting;
      await openWaitingRoom(tester);
      expect(find.text('Waiting for your clinician'), findsOneWidget);

      // The clinician starts the appointment; the next poll picks it up.
      backend.consultation.status = ConsultationStatus.connected;
      backend.consultation.startedAt = DateTime.now();
      await tester.pump(const Duration(seconds: 6));
      await settle(tester);

      expect(find.text('Your appointment has started'), findsOneWidget);
      await tapText(tester, 'Join your appointment');
      expect(find.byType(ConsultationCallScreen), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('offers the care plan once the appointment has ended', (
      tester,
    ) async {
      backend.consultation.status = ConsultationStatus.ended;
      await openWaitingRoom(tester);

      expect(find.text('Your appointment has ended'), findsOneWidget);
      await tapText(tester, 'View your care plan');
      expect(find.byType(CarePlanScreen), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('has a back button that leaves the waiting room', (
      tester,
    ) async {
      await openWaitingRoom(tester);
      await tapBack(tester);
      expect(find.byType(WaitingRoomScreen), findsNothing);

      await disposeApp(tester);
    });
  });

  group('the appointment', () {
    testWidgets('is honest that in-app calling is not there yet', (
      tester,
    ) async {
      backend.consultation
        ..status = ConsultationStatus.connected
        ..startedAt = DateTime.now().subtract(const Duration(minutes: 3));
      await pumpAppAt(
        tester,
        RoutePaths.consultationCall,
        overrides: backend.overrides,
        extra: appointment,
      );

      expect(find.byType(ConsultationCallScreen), findsOneWidget);
      expect(find.text('Dr Sam Okoro'), findsOneWidget);
      // The clinician's initials, not a stock face.
      expect(find.text('SO'), findsOneWidget);
      expect(find.textContaining('Connected •'), findsOneWidget);
      expect(
        find.textContaining("In-app video and audio calling isn't available"),
        findsOneWidget,
      );
      // No pretend controls or recording claims.
      expect(find.text('Mute'), findsNothing);
      expect(find.text('Recording off'), findsNothing);

      await disposeApp(tester);
    });

    testWidgets('ends for real and moves on to the care plan', (tester) async {
      backend.consultation.status = ConsultationStatus.connected;
      await pumpAppAt(
        tester,
        RoutePaths.consultationCall,
        overrides: backend.overrides,
        extra: appointment,
      );

      await tester.tap(find.byIcon(Icons.call_end));
      await settle(tester);
      // The confirmation popup repeats the label as its button.
      await tester.tap(find.text('End appointment').last);
      await settle(tester);

      expect(backend.consultation.calls, contains('transition:ended'));
      expect(find.byType(CarePlanScreen), findsOneWidget);
      expect(
        find.text("Your written plan isn't in the app yet"),
        findsOneWidget,
      );
      expect(find.text('with Dr Sam Okoro'), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('picks up an ending by the clinician', (tester) async {
      backend.consultation.status = ConsultationStatus.connected;
      await pumpAppAt(
        tester,
        RoutePaths.consultationCall,
        overrides: backend.overrides,
        extra: appointment,
      );

      backend.consultation.status = ConsultationStatus.ended;
      await tester.pump(const Duration(seconds: 6));
      await settle(tester);

      expect(find.text('Appointment ended'), findsOneWidget);
      expect(find.text('View your care plan'), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('a care plan opened without a visit says there is none', (
      tester,
    ) async {
      await pumpAppAt(
        tester,
        RoutePaths.careplan,
        overrides: backend.overrides,
      );

      expect(find.text('No care plan yet'), findsOneWidget);
      await tapBack(tester);
      expect(find.byType(CarePlanScreen), findsNothing);

      await disposeApp(tester);
    });
  });
}
