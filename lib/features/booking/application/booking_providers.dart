import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../doctors/domain/models/doctor.dart';
import '../domain/models/availability_slot.dart';
import '../domain/models/clinical_service.dart';
import '../domain/models/my_appointment.dart';

/// The bookable services.
final clinicalServicesProvider = FutureProvider<List<ClinicalService>>(
  (ref) => ref.watch(bookingRepositoryProvider).listServices(),
);

/// Every clinician in the network.
final doctorsProvider = FutureProvider<List<Doctor>>(
  (ref) => ref.watch(bookingRepositoryProvider).listDoctors(),
);

/// One clinician's open appointment times, soonest first.
final availabilityProvider =
    FutureProvider.family<List<AvailabilitySlot>, String>(
      (ref, providerId) =>
          ref.watch(bookingRepositoryProvider).listAvailability(providerId),
    );

/// The signed-in patient's appointments, newest first.
final myAppointmentsProvider = FutureProvider<List<MyAppointment>>(
  (ref) => ref.watch(bookingRepositoryProvider).listMine(),
);
