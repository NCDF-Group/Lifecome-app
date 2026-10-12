import 'package:flutter/material.dart';

/// One row under "What you will explore" / "What we can help with".
class ExploreItem {
  const ExploreItem(this.icon, this.label);
  final IconData icon;
  final String label;
}

/// One step of a coaching journey timeline.
class JourneyStep {
  const JourneyStep(this.title, this.description);
  final String title;
  final String description;
}

/// Everyday-wellbeing service detail content (non-medical support,
/// distinct from the GP-care services in `clinical_service.dart`). One
/// screen (`WellbeingServiceScreen`) renders any of these — see
/// `wellbeingServices` for the three instances the design screenshots show.
class WellbeingService {
  const WellbeingService({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.heroIcon,
    required this.heroColor,
    this.badge,
    this.highlightTitle,
    this.highlightDescription,
    this.exploreHeading = 'What you will explore',
    required this.exploreItems,
    this.journeySteps,
    this.facilitatorLabel = 'facilitator',
    this.extraLinkLabel,
    required this.disclaimer,
    this.footerNote,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData heroIcon;
  final Color heroColor;

  /// Small pill under the subtitle, e.g. "Online sessions".
  final String? badge;

  /// The highlighted green callout card (eating/stress have one; coaching
  /// uses a journey timeline instead).
  final String? highlightTitle;
  final String? highlightDescription;

  final String exploreHeading;
  final List<ExploreItem> exploreItems;

  /// Coaching's numbered "Your coaching journey" timeline.
  final List<JourneyStep>? journeySteps;

  /// "Meet your {facilitator|coach}".
  final String facilitatorLabel;

  /// Stress management's "Need medical support? Explore GP care" link.
  final String? extraLinkLabel;

  final String disclaimer;
  final String? footerNote;
}

const wellbeingServices = [
  WellbeingService(
    id: 'lifestyle-coaching',
    title: 'Lifestyle and wellbeing coaching',
    subtitle: 'Build healthy routines that fit your life.',
    heroIcon: Icons.directions_walk_outlined,
    heroColor: Color(0xFF49AA02),
    badge: 'Online coaching',
    exploreHeading: 'What we can help with',
    exploreItems: [
      ExploreItem(Icons.directions_walk_rounded, 'Healthy daily routines'),
      ExploreItem(Icons.fitness_center_rounded, 'Physical activity'),
      ExploreItem(Icons.bedtime_outlined, 'Sleep habits'),
      ExploreItem(Icons.track_changes_rounded, 'Personal wellbeing goals'),
    ],
    journeySteps: [
      JourneyStep(
        'Discuss what matters to you',
        "Share your goals, lifestyle and what you'd like to change.",
      ),
      JourneyStep(
        'Agree practical next steps',
        'Get personalised guidance and simple, achievable steps.',
      ),
      JourneyStep(
        'Review your progress',
        'Reflect, make adjustments and keep building on your success.',
      ),
    ],
    facilitatorLabel: 'coach',
    disclaimer: 'General wellbeing support, not medical treatment.',
  ),
  WellbeingService(
    id: 'healthy-eating',
    title: 'Healthy eating education',
    subtitle: 'Practical food choices for everyday life.',
    heroIcon: Icons.apple_outlined,
    heroColor: Color(0xFF2F7D00),
    exploreItems: [
      ExploreItem(Icons.eco_outlined, 'General nutrition'),
      ExploreItem(Icons.assignment_outlined, 'Meal planning'),
      ExploreItem(Icons.shopping_cart_outlined, 'Healthy shopping'),
      ExploreItem(Icons.savings_outlined, 'Food choices that fit your budget'),
    ],
    highlightTitle: 'Learn and put it into practice',
    highlightDescription: 'Explore everyday food choices, ask questions and build a practical meal plan.',
    disclaimer: 'For general education, not treatment of dietary conditions.',
  ),
  WellbeingService(
    id: 'stress-management',
    title: 'Stress management and relaxation',
    subtitle: 'Make space for everyday calm.',
    heroIcon: Icons.self_improvement_outlined,
    heroColor: Color(0xFF2F7D00),
    highlightTitle: 'A gentle guided session',
    highlightDescription: 'Try practical techniques at your own pace and discover what works for your everyday wellbeing.',
    badge: 'Online sessions',
    exploreItems: [
      ExploreItem(Icons.chat_bubble_outline_rounded, 'Mindfulness'),
      ExploreItem(Icons.air_rounded, 'Breathing exercises'),
      ExploreItem(Icons.spa_outlined, 'Guided relaxation'),
    ],
    extraLinkLabel: 'Need medical support? Explore GP care',
    disclaimer: 'Wellbeing support, not treatment for mental illness.',
    footerNote: 'General wellbeing support, not medical treatment.',
  ),
];
