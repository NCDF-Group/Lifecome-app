import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/health_records_repository.dart';
import '../domain/models/clinical_note.dart';
import '../domain/models/diagnostic_result.dart';
import '../domain/models/prescription.dart';
import '../domain/models/referral.dart';

final healthRecordsRepositoryProvider = Provider<HealthRecordsRepository>(
  (ref) => const PendingHealthRecordsRepository(),
);

// Each list watches the session epoch, so signing in as someone else never
// shows the previous person's records.

final clinicalNotesProvider = FutureProvider<List<ClinicalNote>>((ref) {
  ref.watch(sessionEpochProvider);
  return ref.watch(healthRecordsRepositoryProvider).notes();
});

final prescriptionsProvider = FutureProvider<List<Prescription>>((ref) {
  ref.watch(sessionEpochProvider);
  return ref.watch(healthRecordsRepositoryProvider).prescriptions();
});

final referralsProvider = FutureProvider<List<Referral>>((ref) {
  ref.watch(sessionEpochProvider);
  return ref.watch(healthRecordsRepositoryProvider).referrals();
});

final diagnosticResultsProvider = FutureProvider<List<DiagnosticResult>>((ref) {
  ref.watch(sessionEpochProvider);
  return ref.watch(healthRecordsRepositoryProvider).results();
});
