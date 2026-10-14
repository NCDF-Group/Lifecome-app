import 'package:flutter/material.dart';

/// One row under "What you will explore" / "What we can help with". [color]
/// overrides the service's own `explorePanelIconColor` for the rare item
/// that stands out from its siblings (e.g. eating's "General nutrition").
class ExploreItem {
  const ExploreItem(this.icon, this.label, {this.color});
  final IconData icon;
  final String label;
  final Color? color;
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
    required this.heroImage,
    this.heroImageAlignment = Alignment.center,
    this.badge,
    this.highlightIcon = Icons.eco_outlined,
    this.highlightTitle,
    this.highlightDescription,
    this.exploreHeading = 'What you will explore',
    required this.exploreItems,
    required this.explorePanelColor,
    required this.explorePanelIconColor,
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

  /// The photo across the top of the detail page (a bundled asset path). The
  /// banner crops it to fit, so [heroImageAlignment] says which part stays in
  /// view. [heroIcon] still marks the service in the Services list.
  final String heroImage;
  final Alignment heroImageAlignment;

  /// Small pill under the subtitle, e.g. "Online sessions".
  final String? badge;

  /// The highlighted callout card (eating/stress have one; coaching uses a
  /// journey timeline instead).
  final IconData highlightIcon;
  final String? highlightTitle;
  final String? highlightDescription;

  final String exploreHeading;
  final List<ExploreItem> exploreItems;

  /// Background tint and icon-circle tint for the explore rows (and the
  /// highlight card) — green for lifestyle/stress, blue for eating.
  final Color explorePanelColor;
  final Color explorePanelIconColor;

  /// Coaching's numbered "Your coaching journey" timeline.
  final List<JourneyStep>? journeySteps;

  /// "Meet your {facilitator|coach}".
  final String facilitatorLabel;

  /// Stress management's "Need medical support? Explore GP care" link.
  final String? extraLinkLabel;

  final String disclaimer;
  final String? footerNote;
}

const _green = Color(0xFFEAF7E8);
const _greenIcon = Color(0xFF2F7D00);
const _blue = Color(0xFFE3EEFB);
const _blueIcon = Color(0xFF0667B8);

const wellbeingServices = [
  WellbeingService(
    id: 'lifestyle-coaching',
    title: 'Lifestyle and wellbeing coaching',
    subtitle: 'Build healthy routines that fit your life.',
    heroIcon: Icons.directions_walk_outlined,
    heroColor: Color(0xFF49AA02),
    heroImage: 'assets/images/wellbeing/lifestyle-coaching.webp',
    badge: 'Online coaching',
    exploreHeading: 'What we can help with',
    explorePanelColor: _green,
    explorePanelIconColor: _greenIcon,
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
    heroImage: 'assets/images/wellbeing/healthy-eating.webp',
    // Her hair reaches the top of the photo, so crop from the bottom first.
    heroImageAlignment: Alignment(0, -0.6),
    explorePanelColor: _blue,
    explorePanelIconColor: _blueIcon,
    exploreItems: [
      ExploreItem(Icons.eco_outlined, 'General nutrition', color: _greenIcon),
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
    heroImage: 'assets/images/wellbeing/stress-management.webp',
    // The photo is very wide and she sits right of centre.
    heroImageAlignment: Alignment(0.5, 0),
    explorePanelColor: _green,
    explorePanelIconColor: _greenIcon,
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
