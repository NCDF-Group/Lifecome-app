import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/consultation_repository.dart';
import '../domain/models/consultation_session.dart';
import '../domain/models/consultation_status.dart';

/// The consultation repository the screens depend on. Overridden in tests.
final consultationRepositoryProvider = Provider<ConsultationRepository>((ref) {
  return DioConsultationRepository(ref.watch(apiClientProvider));
});

/// The steps from arriving to waiting, in the order the backend allows them.
const _checkInPath = [
  ConsultationStatus.booked,
  ConsultationStatus.checkInOpen,
  ConsultationStatus.deviceCheck,
  ConsultationStatus.waiting,
];

/// One appointment's consultation, as the backend sees it. The waiting room
/// polls it until the clinician starts the appointment.
class ConsultationNotifier extends AsyncNotifier<ConsultationSession> {
  ConsultationNotifier(this.appointmentId);

  final String appointmentId;

  @override
  Future<ConsultationSession> build() {
    ref.watch(sessionEpochProvider);
    return ref.watch(consultationRepositoryProvider).getSession(appointmentId);
  }

  /// Loads the state again. A failed poll keeps what is on screen: a dropped
  /// connection for a moment must not throw the person out of the waiting room.
  Future<void> poll() async {
    try {
      final session = await ref
          .read(consultationRepositoryProvider)
          .getSession(appointmentId);
      state = AsyncData(session);
    } catch (_) {
      // Keep the last known state.
    }
  }

  /// Tells the clinician the patient is here, taking the steps the backend
  /// requires (open check-in, device check, waiting) one after another.
  /// Throws an `ApiException` if the backend refuses a step.
  Future<void> checkIn() async {
    final repository = ref.read(consultationRepositoryProvider);
    var session = state.value ?? await future;
    final from = _checkInPath.indexOf(session.status);
    if (from == -1) return;
    for (var step = from + 1; step < _checkInPath.length; step++) {
      session = await repository.transition(appointmentId, _checkInPath[step]);
      state = AsyncData(session);
    }
  }

  /// Ends the consultation from the patient's side.
  Future<void> end() async {
    final session = await ref
        .read(consultationRepositoryProvider)
        .transition(appointmentId, ConsultationStatus.ended);
    state = AsyncData(session);
  }
}

final consultationProvider = AsyncNotifierProvider.autoDispose
    .family<ConsultationNotifier, ConsultationSession, String>(
      ConsultationNotifier.new,
    );
