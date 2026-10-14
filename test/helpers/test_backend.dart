import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:lifecome_mobile/core/providers/core_providers.dart';
import 'package:lifecome_mobile/core/storage/secure_storage.dart';
import 'package:lifecome_mobile/features/auth/data/auth_repository.dart';
import 'package:lifecome_mobile/features/booking/application/booking_controller.dart';
import 'package:lifecome_mobile/features/consultation/application/waiting_room_controller.dart';
import 'package:lifecome_mobile/features/doctors/application/doctor_search_controller.dart';
import 'package:lifecome_mobile/features/notifications/application/notifications_controller.dart';
import 'package:lifecome_mobile/features/profile/application/profile_controller.dart';

import 'fake_auth_repository.dart';
import 'fake_booking_repositories.dart';
import 'fake_notifications_repository.dart';
import 'fake_profile_repository.dart';

/// Stands in for the whole backend in a widget test: one fake per area, all
/// starting out with a signed-in person who has a profile and nothing booked.
/// Change what a test needs, then pass [overrides] to `pumpAppAt`.
class TestBackend {
  final auth = FakeAuthRepository();
  final profiles = FakeProfileRepository();
  final notifications = FakeNotificationsRepository();
  final booking = FakeBookingRepository();
  final doctors = FakeDoctorRepository();
  final consultation = FakeConsultationRepository();

  List<Override> get overrides => [
    authRepositoryProvider.overrideWithValue(auth as AuthRepository),
    tokenStoreProvider.overrideWithValue(MemoryTokenStore()),
    profileRepositoryProvider.overrideWithValue(profiles),
    notificationsRepositoryProvider.overrideWithValue(notifications),
    bookingRepositoryProvider.overrideWithValue(booking),
    doctorRepositoryProvider.overrideWithValue(doctors),
    consultationRepositoryProvider.overrideWithValue(consultation),
  ];
}
