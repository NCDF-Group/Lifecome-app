/// The answers to the menopause assessment (screen pack 063-064), shared
/// with the GP before a menopause consultation.
class MenopauseAssessment {
  const MenopauseAssessment({
    required this.topic,
    required this.priority,
    required this.impact,
    required this.previousCare,
    this.treatment,
    this.history,
  });

  final String topic;
  final String priority;
  final String impact;
  final String previousCare;
  final String? treatment;
  final String? history;

  static const topics = [
    'Changes in symptoms',
    'Sleep and energy',
    'Periods and cycle changes',
    'Mood and wellbeing',
    'Treatment questions',
  ];

  static const impacts = [
    'A little',
    'Moderately',
    'A lot',
    'Prefer to discuss with the GP',
  ];

  static const previousCareOptions = ['No', 'Yes', 'Prefer to discuss'];
}

/// What the person wants to go over at a menopause review (068).
class MenopauseReviewNote {
  const MenopauseReviewNote({
    required this.progress,
    required this.review,
    this.questions,
  });

  final String progress;
  final String review;
  final String? questions;

  static const progressOptions = [
    'Better',
    'About the same',
    'More difficult',
    'Unsure',
  ];
}
