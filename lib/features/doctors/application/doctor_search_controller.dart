import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/doctor_repository.dart';
import '../domain/models/doctor.dart';

/// The clinician directory the screens depend on. Overridden in tests.
final doctorRepositoryProvider = Provider<DoctorRepository>((ref) {
  return DioDoctorRepository(ref.watch(apiClientProvider));
});

/// Every clinician currently taking patients. The booking screens narrow this
/// down (by appointment type, language, area) themselves.
final doctorsProvider = FutureProvider<List<Doctor>>((ref) {
  ref.watch(sessionEpochProvider);
  return ref.watch(doctorRepositoryProvider).listDoctors();
});
