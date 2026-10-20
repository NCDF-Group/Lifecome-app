import '../../../core/widgets/media/lc_icons.dart';

/// One kind of professional care (screen pack 070-074).
class CareService {
  const CareService({
    required this.id,
    required this.title,
    required this.summary,
    required this.description,
    required this.icon,
    required this.steps,
  });

  final String id;
  final String title;

  /// One line, for the catalogue.
  final String summary;

  /// A sentence, for the service's own page.
  final String description;
  final String icon;

  /// How getting this support starts.
  final List<String> steps;

  static const all = [
    CareService(
      id: 'personal',
      title: 'Personal care',
      summary: 'Support with daily personal routines',
      description:
          'Support with daily personal routines, delivered with dignity and '
          'respect.',
      icon: LcIcons.care,
      steps: [
        'Discuss your preferences and routines',
        'Agree the right level of support',
        'Review the plan with your coordinator',
      ],
    ),
    CareService(
      id: 'home',
      title: 'Help at home',
      summary: 'Practical support in the home',
      description:
          'Practical support to help everyday life feel more manageable.',
      icon: LcIcons.home,
      steps: [
        'Discuss tasks and routines',
        'Agree a schedule around your needs',
        'Record preferences in your care plan',
      ],
    ),
    CareService(
      id: 'companionship',
      title: 'Companionship',
      summary: 'Social connection and everyday company',
      description:
          'Time, conversation and support for the everyday activities that '
          'matter to you.',
      icon: LcIcons.people,
      steps: [
        'Discuss interests and preferences',
        'Plan suitable activities together',
        'Agree visit times and continuity',
      ],
    ),
    CareService(
      id: 'respite',
      title: 'Respite support',
      summary: 'Planned support for family carers',
      description:
          'Planned support while a family carer takes time away from their '
          'usual caring role.',
      icon: LcIcons.clock,
      steps: [
        'Understand existing care arrangements',
        'Agree the period and type of support',
        'Plan a clear handover',
      ],
    ),
  ];

  static CareService byTitle(String title) =>
      all.firstWhere((s) => s.title == title, orElse: () => all.first);
}

/// What the person asked for (screen pack 075-078).
class CareRequest {
  const CareRequest({
    required this.forSomeoneElse,
    required this.recipientName,
    required this.postcode,
    required this.need,
    required this.needsDetail,
    required this.days,
    required this.time,
    required this.start,
    required this.phone,
    required this.reference,
    required this.submittedAt,
    this.preferences,
  });

  final bool forSomeoneElse;
  final String recipientName;
  final String postcode;

  /// A [CareService] title.
  final String need;
  final String needsDetail;
  final String? preferences;
  final String days;
  final String time;
  final String start;
  final String phone;
  final String reference;
  final DateTime submittedAt;

  static const dayOptions = [
    'Monday, Wednesday and Friday',
    'Every weekday',
    'Weekends',
    'Every day',
    'Flexible',
  ];
  static const timeOptions = ['Morning', 'Afternoon', 'Evening', 'Flexible'];
  static const startOptions = [
    'Within two weeks',
    'Within a month',
    'I am exploring options',
  ];

  /// The weekdays (1 = Monday) [days] stands for.
  List<int> get weekdays => switch (days) {
    'Every weekday' => [1, 2, 3, 4, 5],
    'Weekends' => [6, 7],
    'Every day' => [1, 2, 3, 4, 5, 6, 7],
    _ => [1, 3, 5],
  };

  /// The visit start time [time] stands for, as "09:00".
  String get visitTime => switch (time) {
    'Afternoon' => '14:00',
    'Evening' => '18:00',
    _ => '09:00',
  };
}

/// A change the person asked for (screen pack 089).
class CareChangeRequest {
  const CareChangeRequest({
    required this.type,
    required this.detail,
    required this.sentAt,
  });

  final String type;
  final String detail;
  final DateTime sentAt;

  static const types = [
    'Visit time or day',
    'Type of support',
    'Care preferences',
    'Pause or end care',
    'Care proposal',
  ];
}

/// One scheduled visit, worked out from the agreed days and time.
class CareVisit {
  const CareVisit({required this.date, required this.time});

  final DateTime date;
  final String time;
}
