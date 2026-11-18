import '../../../core/network/api_client.dart';
import '../domain/wellbeing_models.dart';

/// Patient wellbeing data shared with the admin console through the backend.
abstract interface class WellbeingRepository {
  Future<List<WellbeingOffer>> listOffers();
  Future<List<WellbeingSession>> listSessions(List<WellbeingOffer> offers);
  Future<WellbeingSession> bookSession({
    required List<WellbeingOffer> offers,
    required WellbeingOffer offer,
    required String practitionerName,
    required DateTime startsAt,
    required String notes,
  });
  Future<WellbeingSession> cancelSession(
    String id,
    List<WellbeingOffer> offers,
  );
  Future<WellbeingPlan?> getPlan();
  Future<WellbeingPlan?> savePlan(String goal);
  Future<WellbeingPlan?> setStepCompleted(String stepId, bool completed);
  Future<List<WellbeingCheckIn>> listCheckIns();
  Future<WellbeingCheckIn> submitCheckIn({
    required int rating,
    required String wentWell,
  });
}

class DioWellbeingRepository implements WellbeingRepository {
  DioWellbeingRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<WellbeingOffer>> listOffers() async => [
    for (final row in await _client.getList('/wellbeing/sessions/catalogue'))
      if (row is Map<String, dynamic>) WellbeingOffer.fromJson(row),
  ];

  @override
  Future<List<WellbeingSession>> listSessions(
    List<WellbeingOffer> offers,
  ) async => [
    for (final row in await _client.getList('/wellbeing/sessions'))
      if (row is Map<String, dynamic>)
        WellbeingSession.fromJson(row, offers: offers),
  ];

  @override
  Future<WellbeingSession> bookSession({
    required List<WellbeingOffer> offers,
    required WellbeingOffer offer,
    required String practitionerName,
    required DateTime startsAt,
    required String notes,
  }) async {
    final json = await _client.post(
      '/wellbeing/sessions/book',
      data: {
        'sessionType': offer.sessionType,
        'coachName': practitionerName,
        'scheduledAt': startsAt.toUtc().toIso8601String(),
        'durationMinutes': offer.durationMinutes,
        if (notes.trim().isNotEmpty) 'notes': notes.trim(),
      },
    );
    return WellbeingSession.fromJson(json, offers: offers);
  }

  @override
  Future<WellbeingSession> cancelSession(
    String id,
    List<WellbeingOffer> offers,
  ) async => WellbeingSession.fromJson(
    await _client.post('/wellbeing/sessions/$id/cancel'),
    offers: offers,
  );

  @override
  Future<WellbeingPlan?> getPlan() async {
    final json = await _client.get('/wellbeing/plan');
    final value = json['plan'];
    return value is Map<String, dynamic> ? WellbeingPlan.fromJson(value) : null;
  }

  @override
  Future<WellbeingPlan?> savePlan(String goal) async {
    final json = await _client.put('/wellbeing/plan', data: {'goal': goal});
    final value = json['plan'];
    return value is Map<String, dynamic> ? WellbeingPlan.fromJson(value) : null;
  }

  @override
  Future<WellbeingPlan?> setStepCompleted(
    String stepId,
    bool completed,
  ) async {
    final json = await _client.patch(
      '/wellbeing/plan/steps/$stepId',
      data: {'completed': completed},
    );
    final value = json['plan'];
    return value is Map<String, dynamic> ? WellbeingPlan.fromJson(value) : null;
  }

  @override
  Future<List<WellbeingCheckIn>> listCheckIns() async => [
    for (final row in await _client.getList('/wellbeing/check-ins'))
      if (row is Map<String, dynamic>) WellbeingCheckIn.fromJson(row),
  ];

  @override
  Future<WellbeingCheckIn> submitCheckIn({
    required int rating,
    required String wentWell,
  }) async => WellbeingCheckIn.fromJson(
    await _client.post(
      '/wellbeing/check-ins',
      data: {'rating': rating, if (wentWell.trim().isNotEmpty) 'wentWell': wentWell.trim()},
    ),
  );
}
