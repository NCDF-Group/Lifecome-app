import '../../../core/widgets/media/lc_icons.dart';

/// One kind of wellbeing session (screen pack 092-094).
class WellbeingOffer {
  const WellbeingOffer({
    required this.id,
    required this.title,
    required this.summary,
    required this.description,
    required this.icon,
    required this.heroImage,
    required this.steps,
    required this.pricePence,
    this.note,
  });

  final String id;
  final String title;

  /// One line, for the hub.
  final String summary;

  /// A sentence, for the offer's own page.
  final String description;
  final String icon;
  final String heroImage;
  final List<String> steps;

  /// Example price for the preview.
  final int pricePence;

  /// A safety or scope note shown on the offer's page.
  final String? note;

  static const durationMinutes = 30;

  static const all = [
    WellbeingOffer(
      id: 'lifestyle',
      title: 'Lifestyle coaching',
      summary: 'Build routines around your goals',
      description: 'Create realistic routines that fit your life.',
      icon: LcIcons.wellbeing,
      heroImage: 'assets/images/wellbeing/lifestyle-coaching.webp',
      steps: [
        'Explore the habits that matter to you',
        'Set a manageable personal goal',
        'Review your progress with a practitioner',
      ],
      pricePence: 4500,
    ),
    WellbeingOffer(
      id: 'eating',
      title: 'Healthy eating',
      summary: 'Education and support for everyday choices',
      description:
          'Practical education to help you think about everyday food choices.',
      icon: LcIcons.leaf,
      heroImage: 'assets/images/wellbeing/healthy-eating.webp',
      steps: [
        'Talk about your routines and preferences',
        'Explore general healthy eating information',
        'Choose a practical next step',
      ],
      pricePence: 4500,
      note:
          'If you need clinical dietary advice or have a medical condition, '
          'talk to your GP about the right professional support.',
    ),
    WellbeingOffer(
      id: 'stress',
      title: 'Stress & relaxation',
      summary: 'Make space for your wellbeing',
      description:
          'A supportive space to reflect on everyday stress and relaxation.',
      icon: LcIcons.care,
      heroImage: 'assets/images/wellbeing/stress-management.webp',
      steps: [
        'Discuss everyday pressures',
        'Explore general relaxation approaches',
        'Build a routine you can sustain',
      ],
      pricePence: 3500,
      note:
          'This is general wellbeing support, not crisis care. If you feel '
          'unsafe or in crisis, use urgent help.',
    ),
  ];
}

/// A booked wellbeing session (screen pack 097-101).
class WellbeingSession {
  const WellbeingSession({
    required this.offer,
    required this.startsAt,
    required this.goal,
    required this.reference,
    this.cancelled = false,
    this.cancelReason,
  });

  final WellbeingOffer offer;
  final DateTime startsAt;
  final String goal;
  final String reference;
  final bool cancelled;
  final String? cancelReason;

  WellbeingSession copyWith({
    DateTime? startsAt,
    bool? cancelled,
    String? cancelReason,
  }) => WellbeingSession(
    offer: offer,
    startsAt: startsAt ?? this.startsAt,
    goal: goal,
    reference: reference,
    cancelled: cancelled ?? this.cancelled,
    cancelReason: cancelReason ?? this.cancelReason,
  );
}

/// A weekly check-in on the wellbeing plan (screen pack 104).
class WellbeingCheckIn {
  const WellbeingCheckIn({
    required this.score,
    required this.at,
    this.reflection,
  });

  /// 1 (more difficult) to 5 (very manageable).
  final int score;
  final DateTime at;
  final String? reflection;
}

/// The example practitioner shown in the preview.
abstract final class WellbeingPractitioner {
  static const name = 'Jordan Ellis';
  static const role = 'Wellbeing practitioner (example)';
}
