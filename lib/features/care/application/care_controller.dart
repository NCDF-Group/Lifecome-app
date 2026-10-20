import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../domain/care_models.dart';

/// Where the person's care stands. Professional Care has no backend yet, so
/// this is preview data kept in memory for the session (signing out clears
/// it): nothing is sent to a care provider.
class CareState {
  const CareState({
    this.request,
    this.accepted = false,
    this.changes = const [],
  });

  final CareRequest? request;

  /// The proposal has been accepted.
  final bool accepted;
  final List<CareChangeRequest> changes;

  /// Illustrative pricing for the proposal (pack 082).
  static const hourlyRatePence = 3000;
  static const hoursPerVisit = 2;

  int get visitsPerWeek => request?.weekdays.length ?? 0;
  int get weeklyTotalPence => visitsPerWeek * hoursPerVisit * hourlyRatePence;

  /// The assessment call: three days after the request, at 11:00.
  DateTime? get assessmentAt {
    final sent = request?.submittedAt;
    if (sent == null) return null;
    final day = DateTime(sent.year, sent.month, sent.day + 3, 11);
    return day;
  }

  /// When visits start: a week after the request.
  DateTime? get startsOn {
    final sent = request?.submittedAt;
    if (sent == null) return null;
    return DateTime(sent.year, sent.month, sent.day + 7);
  }

  /// The next [count] visits from [startsOn] on the agreed weekdays.
  List<CareVisit> upcomingVisits({int count = 6}) {
    final request = this.request;
    final start = startsOn;
    if (request == null || start == null || !accepted) return const [];
    final visits = <CareVisit>[];
    for (var d = 0; visits.length < count && d < 60; d++) {
      final day = DateTime(start.year, start.month, start.day + d);
      if (request.weekdays.contains(day.weekday)) {
        visits.add(CareVisit(date: day, time: request.visitTime));
      }
    }
    return visits;
  }

  CareState copyWith({
    CareRequest? request,
    bool? accepted,
    List<CareChangeRequest>? changes,
  }) => CareState(
    request: request ?? this.request,
    accepted: accepted ?? this.accepted,
    changes: changes ?? this.changes,
  );
}

class CareController extends Notifier<CareState> {
  @override
  CareState build() {
    ref.watch(sessionEpochProvider);
    return const CareState();
  }

  void submit(CareRequest request) =>
      state = CareState(request: request, changes: state.changes);

  void accept() => state = state.copyWith(accepted: true);

  void requestChange(CareChangeRequest change) =>
      state = state.copyWith(changes: [...state.changes, change]);
}

final careProvider = NotifierProvider<CareController, CareState>(
  CareController.new,
);
