import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lifecome_mobile/core/router/route_paths.dart';
import 'package:lifecome_mobile/features/insurance/presentation/insurance_claims_screens.dart';
import 'package:lifecome_mobile/features/insurance/presentation/insurance_hub_screens.dart';
import 'package:lifecome_mobile/features/insurance/presentation/insurance_policy_screens.dart';
import 'package:lifecome_mobile/features/payer/presentation/hmo_coverage_screen.dart';
import 'package:lifecome_mobile/features/payer/presentation/link_health_plan_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Finder field(int index) => find.byType(TextField).at(index);

  testWidgets('Home Insurance card opens the hub', (tester) async {
    await pumpAppAt(tester, RoutePaths.home, overrides: backend.overrides);
    await tapText(tester, 'Insurance');
    expect(find.byType(InsuranceHubScreen), findsOneWidget);
    expect(find.text('Cover with clarity'), findsOneWidget);

    await disposeApp(tester);
  });

  testWidgets('an enquiry needs consent and issues no policy', (tester) async {
    await pumpAppAt(tester, RoutePaths.insurance, overrides: backend.overrides);
    await tapText(tester, 'Explore insurance');
    await tapText(tester, 'Health insurance');
    await tapText(tester, 'Start an enquiry');
    expect(find.byType(InsuranceEnquiryScreen), findsOneWidget);

    await tester.enterText(field(2), '07700 900123');
    await tapText(tester, 'Continue');
    expect(find.text('Review your enquiry'), findsOneWidget);
    await tapText(tester, 'Continue to provider step');
    expect(find.text('Please confirm to continue.'), findsOneWidget);
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tapText(tester, 'Continue to provider step');
    await tapText(tester, 'Finish enquiry');
    expect(find.byType(InsuranceEnquirySentScreen), findsOneWidget);
    expect(find.textContaining('No quotation or policy'), findsOneWidget);

    await disposeApp(tester);
  });

  testWidgets('with no plan, policies and cover check offer to link one', (
    tester,
  ) async {
    await pumpAppAt(
      tester,
      RoutePaths.insuranceCover,
      overrides: backend.overrides,
    );
    expect(find.text('No policy linked yet'), findsOneWidget);
    await tapText(tester, 'Link a policy');
    expect(find.byType(LinkHealthPlanScreen), findsOneWidget);

    await disposeApp(tester);
  });

  testWidgets('a verified plan shows under policies and checks real cover', (
    tester,
  ) async {
    await pumpAppAt(
      tester,
      RoutePaths.payerSelectHmo,
      overrides: backend.overrides,
    );
    await tapText(tester, 'Bupa');
    await tester.enterText(field(0), 'bp-123456');
    await tester.pump();
    await tapText(tester, 'Verify membership');
    expect(find.byType(HmoCoverageScreen), findsOneWidget);

    GoRouter.of(tester.element(find.byType(HmoCoverageScreen)))
        .go(RoutePaths.insurancePolicies);
    await settle(tester);
    expect(find.byType(InsurancePoliciesScreen), findsOneWidget);
    expect(find.text('Bupa'), findsOneWidget);

    await tapText(tester, 'Bupa');
    expect(find.byType(InsurancePolicyScreen), findsOneWidget);
    expect(find.text('•••• 3456'), findsOneWidget);
    await tapText(tester, 'What it covers');
    expect(find.byType(HmoCoverageScreen), findsOneWidget);

    await disposeApp(tester);
  });

  testWidgets('a claim enquiry is recorded, not decided', (tester) async {
    await pumpAppAt(
      tester,
      RoutePaths.insuranceClaims,
      overrides: backend.overrides,
    );
    expect(find.text('You have no claim enquiries.'), findsOneWidget);
    await tapText(tester, 'Start a claim enquiry');
    await tester.enterText(field(0), 'A GP visit I would like to claim for');
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tapText(tester, 'Send claim enquiry');
    expect(find.byType(InsuranceClaimSentScreen), findsOneWidget);

    await tapText(tester, 'View claims & support');
    expect(find.textContaining('Claim enquiry LC-CLM-'), findsOneWidget);

    await disposeApp(tester);
  });
}
