import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../domain/wellbeing_models.dart';

/// The person's wellbeing session, plan focus and check-ins.
///
/// Wellbeing sessions have no backend yet, so this is preview data kept in
/// memory for the session (signing out clears it). Nothing is booked with a
/// practitioner and nothing is charged.
class WellbeingState {
  const WellbeingState({this.session, this.checkIns = const []});

  final WellbeingSession? session;
  final List<WellbeingCheckIn> checkIns;

  WellbeingCheckIn? get latestCheckIn =>
      checkIns.isEmpty ? null : checkIns.last;
}

class WellbeingController extends Notifier<WellbeingState> {
  @override
  WellbeingState build() {
    ref.watch(sessionEpochProvider);
    return const WellbeingState();
  }

  void book({
    required WellbeingOffer offer,
    required DateTime startsAt,
    required String goal,
  }) => state = WellbeingState(
    session: WellbeingSession(
      offer: offer,
      startsAt: startsAt,
      goal: goal,
      reference: 'LC-WB-${1000 + Random().nextInt(9000)}',
    ),
    checkIns: state.checkIns,
  );

  void reschedule(DateTime startsAt) {
    final session = state.session;
    if (session == null) return;
    state = WellbeingState(
      session: session.copyWith(startsAt: startsAt),
      checkIns: state.checkIns,
    );
  }

  void cancel(String reason) {
    final session = state.session;
    if (session == null) return;
    state = WellbeingState(
      session: session.copyWith(cancelled: true, cancelReason: reason),
      checkIns: state.checkIns,
    );
  }

  void checkIn(WellbeingCheckIn checkIn) => state = WellbeingState(
    session: state.session,
    checkIns: [...state.checkIns, checkIn],
  );
}

final wellbeingProvider = NotifierProvider<WellbeingController, WellbeingState>(
  WellbeingController.new,
);

/// Example session times: the next four weekdays, six times a day.
List<DateTime> wellbeingSlots({DateTime? from}) {
  final now = from ?? DateTime.now();
  final days = <DateTime>[];
  for (var d = 1; days.length < 4; d++) {
    final day = DateTime(now.year, now.month, now.day + d);
    if (day.weekday <= 5) days.add(day);
  }
  const times = [(9, 0), (10, 30), (12, 15), (14, 0), (16, 30), (18, 0)];
  return [
    for (final day in days)
      for (final (h, m) in times) DateTime(day.year, day.month, day.day, h, m),
  ];
}
