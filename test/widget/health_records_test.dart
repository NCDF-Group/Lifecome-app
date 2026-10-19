import 'package:flutter_test/flutter_test.dart';
import 'package:lifecome_mobile/core/router/route_paths.dart';
import 'package:lifecome_mobile/features/gp/presentation/gp_hub_screen.dart';
import 'package:lifecome_mobile/features/health_records/domain/models/clinical_note.dart';
import 'package:lifecome_mobile/features/health_records/domain/models/diagnostic_result.dart';
import 'package:lifecome_mobile/features/health_records/domain/models/prescription.dart';
import 'package:lifecome_mobile/features/health_records/domain/models/referral.dart';
import 'package:lifecome_mobile/features/health_records/presentation/diagnostic_result_screen.dart';
import 'package:lifecome_mobile/features/health_records/presentation/prescription_detail_screen.dart';
import 'package:lifecome_mobile/features/health_records/presentation/record_detail_screen.dart';
import 'package:lifecome_mobile/features/health_records/presentation/records_list_screen.dart';
import 'package:lifecome_mobile/features/health_records/presentation/referral_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/pump_app.dart';
import '../helpers/test_backend.dart';
import '../helpers/test_fonts.dart';

void main() {
  setUpAll(loadManrope);

  late TestBackend backend;
  final day = DateTime(2026, 10, 21);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    backend = TestBackend();
  });

  testWidgets('with nothing shared, offers GP services', (tester) async {
    await pumpAppAt(
      tester,
      RoutePaths.healthRecords,
      overrides: backend.overrides,
    );
    expect(find.text('Your records will appear here'), findsOneWidget);
    await tapText(tester, 'Explore GP services');
    expect(find.byType(GpHubScreen), findsOneWidget);

    await disposeApp(tester);
  });

  testWidgets('an empty list says so', (tester) async {
    await pumpAppAt(
      tester,
      RoutePaths.healthRecords,
      overrides: backend.overrides,
    );
    await tapText(tester, 'Prescriptions');
    expect(find.byType(RecordsListScreen), findsOneWidget);
    expect(find.text('You have no prescriptions.'), findsOneWidget);
    expect(
      find.text('Booking a consultation does not guarantee a prescription.'),
      findsOneWidget,
    );

    await disposeApp(tester);
  });

  testWidgets('each kind of record opens its detail, as written', (
    tester,
  ) async {
    backend.records
      ..noteList = [
        ClinicalNote(
          id: 'n1',
          title: 'GP consultation summary',
          clinician: 'Dr Sam Okoro',
          date: day,
          summary: 'Discussed sleep. Review in four weeks.',
        ),
      ]
      ..prescriptionList = [
        Prescription(
          id: 'p1',
          reference: 'RX-001',
          clinician: 'Dr Sam Okoro',
          issuedOn: day,
          status: 'Issued',
          medicine: 'Example medicine',
          instructions: 'As directed by your clinician.',
        ),
      ]
      ..referralList = [
        Referral(
          id: 'r1',
          reference: 'REF-001',
          specialty: 'Dermatology',
          status: 'Awaiting arrangement',
          createdOn: day,
          nextStep: 'The clinic will contact you',
        ),
      ]
      ..resultList = [
        DiagnosticResult(
          id: 't1',
          title: 'Blood test',
          reviewedBy: 'Dr Sam Okoro',
          date: day,
          report: 'Reviewed. No action needed.',
        ),
      ];

    await pumpAppAt(
      tester,
      RoutePaths.healthRecords,
      overrides: backend.overrides,
    );
    expect(find.text('Your records will appear here'), findsNothing);
    expect(find.text('1 record'), findsNWidgets(4));

    for (final (section, row, screen, text) in [
      (
        'Consultation notes',
        'GP consultation summary',
        RecordDetailScreen,
        'Discussed sleep. Review in four weeks.',
      ),
      ('Prescriptions', 'Example medicine', PrescriptionDetailScreen, 'RX-001'),
      ('Referrals', 'Dermatology', ReferralDetailScreen, 'REF-001'),
      (
        'Test results',
        'Blood test',
        DiagnosticResultScreen,
        'Reviewed. No action needed.',
      ),
    ]) {
      await tapText(tester, section);
      await tapText(tester, row);
      expect(find.byType(screen), findsOneWidget);
      expect(find.text(text), findsOneWidget);
      await tapBack(tester);
      await tapBack(tester);
    }

    await disposeApp(tester);
  });
}
