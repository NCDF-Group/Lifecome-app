import '../../../core/widgets/media/lc_icons.dart';

/// A wellbeing service returned by `/wellbeing/sessions/catalogue`.
class WellbeingOffer {
  const WellbeingOffer({
    required this.id,
    required this.sessionType,
    required this.title,
    required this.summary,
    required this.description,
    required this.icon,
    required this.heroImage,
    required this.durationMinutes,
    required this.pricePence,
    required this.availableCoaches,
  });

  factory WellbeingOffer.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? '';
    final type = json['sessionType'] as String? ?? id;
    final art = switch (id) {
      'lifestyle-coaching' => (
        'assets/images/wellbeing/lifestyle-coaching.webp',
        LcIcons.wellbeing,
      ),
      'healthy-eating' => (
        'assets/images/wellbeing/healthy-eating.webp',
        LcIcons.leaf,
      ),
      'stress-management' => (
        'assets/images/wellbeing/stress-management.webp',
        LcIcons.care,
      ),
      _ => (
        'assets/images/wellbeing/lifestyle-coaching.webp',
        LcIcons.wellbeing,
      ),
    };
    return WellbeingOffer(
      id: id,
      sessionType: type,
      title: (json['title'] as String? ?? '').trim(),
      summary: (json['headline'] as String? ?? '').trim(),
      description: (json['description'] as String? ?? '').trim(),
      icon: art.$2,
      heroImage: art.$1,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 30,
      pricePence: (json['pricePence'] as num?)?.toInt() ?? 0,
      availableCoaches: [
        for (final coach
            in json['availableCoaches'] as List<dynamic>? ?? const [])
          if (coach is String && coach.trim().isNotEmpty) coach.trim(),
      ],
    );
  }

  final String id;
  final String sessionType;
  final String title;
  final String summary;
  final String description;
  final String icon;
  final String heroImage;
  final int durationMinutes;
  final int pricePence;
  final List<String> availableCoaches;
}

/// A booked session returned by `/wellbeing/sessions`.
class WellbeingSession {
  const WellbeingSession({
    required this.id,
    required this.offer,
    required this.startsAt,
    required this.practitionerName,
    required this.status,
    this.notes,
    this.meetingLink,
  });

  factory WellbeingSession.fromJson(
    Map<String, dynamic> json, {
    required List<WellbeingOffer> offers,
  }) {
    final sessionType = json['sessionType'] as String? ?? '';
    WellbeingOffer? offer;
    for (final item in offers) {
      if (item.sessionType == sessionType) {
        offer = item;
        break;
      }
    }
    return WellbeingSession(
      id: json['id'] as String? ?? '',
      offer:
          offer ??
          WellbeingOffer.fromJson({
            'id': sessionType,
            'sessionType': sessionType,
            'title': json['title'] as String? ?? '',
            'headline': '',
            'description': '',
            'durationMinutes': json['durationMinutes'],
            'pricePence': 0,
            'availableCoaches': const <String>[],
          }),
      startsAt: DateTime.parse(json['scheduledAt'] as String).toUtc(),
      practitionerName: (json['coachName'] as String? ?? '').trim(),
      status: (json['status'] as String? ?? '').trim(),
      notes: (json['notes'] as String?)?.trim(),
      meetingLink: (json['meetingLink'] as String?)?.trim(),
    );
  }

  final String id;
  final WellbeingOffer offer;
  final DateTime startsAt;
  final String practitionerName;
  final String status;
  final String? notes;
  final String? meetingLink;

  bool get isCancelled => status.toLowerCase() == 'cancelled';
  bool get isUpcoming => !isCancelled && startsAt.isAfter(DateTime.now());
}

class WellbeingPlan {
  const WellbeingPlan({
    required this.id,
    required this.goal,
    required this.steps,
  });

  factory WellbeingPlan.fromJson(Map<String, dynamic> json) => WellbeingPlan(
    id: json['id'] as String? ?? '',
    goal: json['goal'] as String? ?? '',
    steps: [
      for (final value in json['steps'] as List<dynamic>? ?? const [])
        if (value is Map<String, dynamic>) WellbeingPlanStep.fromJson(value),
    ],
  );

  final String id;
  final String goal;
  final List<WellbeingPlanStep> steps;
}

class WellbeingPlanStep {
  const WellbeingPlanStep({
    required this.id,
    required this.title,
    required this.description,
    required this.completed,
  });

  factory WellbeingPlanStep.fromJson(Map<String, dynamic> json) =>
      WellbeingPlanStep(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        completed: json['completedAt'] != null,
      );

  final String id;
  final String title;
  final String description;
  final bool completed;
}

class WellbeingCheckIn {
  const WellbeingCheckIn({
    required this.id,
    required this.score,
    required this.at,
    this.wentWell,
    this.helpWith,
  });

  factory WellbeingCheckIn.fromJson(Map<String, dynamic> json) =>
      WellbeingCheckIn(
        id: json['id'] as String? ?? '',
        score: (json['rating'] as num?)?.toInt() ?? 0,
        at: DateTime.parse(json['createdAt'] as String).toUtc(),
        wentWell: json['wentWell'] as String?,
        helpWith: json['helpWith'] as String?,
      );

  final String id;
  final int score;
  final DateTime at;
  final String? wentWell;
  final String? helpWith;
}
