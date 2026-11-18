import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../doctors/application/doctor_search_controller.dart';
import '../../doctors/domain/models/doctor.dart';
import '../data/wellbeing_repository.dart';
import '../domain/wellbeing_models.dart';

final wellbeingRepositoryProvider = Provider<WellbeingRepository>((ref) {
  return DioWellbeingRepository(ref.watch(apiClientProvider));
});

class WellbeingState {
  const WellbeingState({
    this.offers = const [],
    this.sessions = const [],
    this.plan,
    this.checkIns = const [],
  });

  final List<WellbeingOffer> offers;
  final List<WellbeingSession> sessions;
  final WellbeingPlan? plan;
  final List<WellbeingCheckIn> checkIns;

  WellbeingSession? get latestSession {
    final sorted = [...sessions]
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    for (final session in sorted) {
      if (session.isUpcoming) return session;
    }
    return sorted.isEmpty ? null : sorted.last;
  }

  WellbeingCheckIn? get latestCheckIn =>
      checkIns.isEmpty ? null : checkIns.first;

  WellbeingState copyWith({
    List<WellbeingOffer>? offers,
    List<WellbeingSession>? sessions,
    WellbeingPlan? plan,
    bool clearPlan = false,
    List<WellbeingCheckIn>? checkIns,
  }) => WellbeingState(
    offers: offers ?? this.offers,
    sessions: sessions ?? this.sessions,
    plan: clearPlan ? null : plan ?? this.plan,
    checkIns: checkIns ?? this.checkIns,
  );
}

/// Wellbeing services, sessions, plans, and check-ins from the authenticated API.
class WellbeingController extends AsyncNotifier<WellbeingState> {
  @override
  Future<WellbeingState> build() async {
    ref.watch(sessionEpochProvider);
    return _load(ref.watch(wellbeingRepositoryProvider));
  }

  Future<WellbeingState> _load(WellbeingRepository repository) async {
    final offers = await repository.listOffers();
    final results = await Future.wait<Object?>([
      repository.listSessions(offers),
      repository.getPlan(),
      repository.listCheckIns(),
    ]);
    return WellbeingState(
      offers: offers,
      sessions: results[0]! as List<WellbeingSession>,
      plan: results[1] as WellbeingPlan?,
      checkIns: results[2]! as List<WellbeingCheckIn>,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _load(ref.read(wellbeingRepositoryProvider)),
    );
  }

  Future<WellbeingSession> book({
    required WellbeingOffer offer,
    required String practitionerName,
    required DateTime startsAt,
    required String notes,
  }) async {
    final current = state.requireValue;
    final session = await ref
        .read(wellbeingRepositoryProvider)
        .bookSession(
          offers: current.offers,
          offer: offer,
          practitionerName: practitionerName,
          startsAt: startsAt,
          notes: notes,
        );
    state = AsyncData(
      current.copyWith(sessions: [session, ...current.sessions]),
    );
    return session;
  }

  Future<void> cancel(String id) async {
    final current = state.requireValue;
    final cancelled = await ref
        .read(wellbeingRepositoryProvider)
        .cancelSession(id, current.offers);
    state = AsyncData(
      current.copyWith(
        sessions: [
          for (final session in current.sessions)
            if (session.id == id) cancelled else session,
        ],
      ),
    );
  }

  Future<void> savePlan(String goal) async {
    final current = state.requireValue;
    final plan = await ref.read(wellbeingRepositoryProvider).savePlan(goal);
    state = AsyncData(current.copyWith(plan: plan, clearPlan: plan == null));
  }

  Future<void> setStepCompleted(String id, bool completed) async {
    final current = state.requireValue;
    final plan = await ref
        .read(wellbeingRepositoryProvider)
        .setStepCompleted(id, completed);
    state = AsyncData(current.copyWith(plan: plan, clearPlan: plan == null));
  }

  Future<void> submitCheckIn({
    required int rating,
    required String wentWell,
  }) async {
    final current = state.requireValue;
    final checkIn = await ref
        .read(wellbeingRepositoryProvider)
        .submitCheckIn(rating: rating, wentWell: wentWell);
    final checkIns = [checkIn, ...current.checkIns];
    final plan = await ref.read(wellbeingRepositoryProvider).getPlan();
    state = AsyncData(
      current.copyWith(checkIns: checkIns, plan: plan, clearPlan: plan == null),
    );
  }
}

final wellbeingProvider =
    AsyncNotifierProvider<WellbeingController, WellbeingState>(
      WellbeingController.new,
    );

/// Active wellbeing practitioners currently listed by the backend directory.
final wellbeingPractitionersProvider = FutureProvider<List<Doctor>>((
  ref,
) async {
  ref.watch(sessionEpochProvider);
  final providers = await ref.watch(doctorRepositoryProvider).listDoctors();
  return [
    for (final provider in providers)
      if (provider.specialty.toLowerCase().contains('wellbeing') &&
          provider.modes.any((mode) => mode.isOnline))
        provider,
  ];
});
