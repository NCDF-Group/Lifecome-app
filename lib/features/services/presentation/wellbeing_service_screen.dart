import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../domain/models/wellbeing_service.dart';

/// Renders any entry of [wellbeingServices] — the three everyday-wellbeing
/// detail pages. Matches the shared structure across the design
/// screenshots: hero banner, tag chip, optional badge, optional highlight
/// card or journey timeline, explore list, and the facilitator /
/// employer-access / disclaimer footer.
class WellbeingServiceScreen extends StatelessWidget {
  const WellbeingServiceScreen({super.key, required this.service});

  final WellbeingService service;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: AppHeaderBar(showBack: true, onBack: () => context.pop()),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: context.palette
                          .adapt(service.heroColor)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Icon(
                        service.heroIcon,
                        size: 56,
                        color: context.palette.adapt(service.heroColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: context.palette.tintGreen,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Everyday wellbeing',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.palette.positive,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    service.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: context.palette.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.palette.inkMuted,
                      height: 1.4,
                    ),
                  ),
                  if (service.badge != null &&
                      service.highlightTitle == null) ...[
                    const SizedBox(height: 10),
                    _BadgePill(label: service.badge!),
                  ],
                  if (service.highlightTitle != null) ...[
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.palette.adapt(service.explorePanelColor),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: context.palette.elevated
                                .withValues(alpha: 0.6),
                            child: Icon(
                              service.highlightIcon,
                              size: 18,
                              color: context.palette.adapt(
                                service.explorePanelIconColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service.highlightTitle!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: context.palette.ink,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  service.highlightDescription ?? '',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: context.palette.inkMuted,
                                    height: 1.4,
                                  ),
                                ),
                                if (service.badge != null) ...[
                                  const SizedBox(height: 10),
                                  _BadgePill(label: service.badge!),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  Text(
                    service.exploreHeading,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: context.palette.ink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final item in service.exploreItems) ...[
                    _ExploreRow(
                      item: item,
                      background: context.palette.adapt(
                        service.explorePanelColor,
                      ),
                      defaultIconColor: context.palette.adapt(
                        service.explorePanelIconColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (service.journeySteps != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Your coaching journey',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: context.palette.ink,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.palette.adapt(service.explorePanelColor),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: _Journey(steps: service.journeySteps!),
                    ),
                  ],
                  const SizedBox(height: 18),
                  _LinkRow(
                    icon: Icons.person_outline,
                    label: 'Meet your ${service.facilitatorLabel}',
                    sublabel: 'Explore profiles and session options.',
                    onTap: () => showComingSoonPopup(
                      context,
                      feature: 'Facilitator profiles',
                    ),
                  ),
                  const SizedBox(height: 10),
                  _LinkRow(
                    icon: Icons.badge_outlined,
                    label: 'Employer access',
                    sublabel: 'Check whether this service is included.',
                    onTap: () => showComingSoonPopup(
                      context,
                      feature: 'Employer access',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: context.palette.inkMuted,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          service.disclaimer,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.palette.inkMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (service.extraLinkLabel != null) ...[
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () =>
                          showComingSoonPopup(context, feature: 'GP care'),
                      child: Row(
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 15,
                            color: context.palette.accent,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              service.extraLinkLabel!,
                              style: TextStyle(
                                fontSize: 13,
                                color: context.palette.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: context.palette.accent,
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  PrimaryButton(
                    label: 'View sessions and prices',
                    icon: Icons.arrow_forward,
                    onPressed: () => showComingSoonPopup(
                      context,
                      feature: 'Session booking',
                    ),
                  ),
                  if (service.footerNote != null) ...[
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        service.footerNote!,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.palette.inkMuted,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExploreRow extends StatelessWidget {
  const _ExploreRow({
    required this.item,
    required this.background,
    required this.defaultIconColor,
  });

  final ExploreItem item;
  final Color background;
  final Color defaultIconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: context.palette.elevated,
            child: Icon(
              item.icon,
              size: 18,
              color: context.palette.adapt(item.color ?? defaultIconColor),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              item.label,
              style: TextStyle(
                fontSize: 15,
                color: context.palette.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(Icons.chevron_right, size: 20, color: context.palette.accent),
        ],
      ),
    );
  }
}

class _Journey extends StatelessWidget {
  const _Journey({required this.steps});

  final List<JourneyStep> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == steps.length - 1 ? 0 : 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.greenStrong,
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    if (i != steps.length - 1)
                      Container(
                        width: 2,
                        height: 36,
                        color: AppColors.greenStrong.withValues(alpha: 0.3),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        steps[i].title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: context.palette.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        steps[i].description,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: context.palette.inkMuted,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.palette.tintBlue,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: context.palette.elevated,
                child: Icon(icon, size: 18, color: context.palette.accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: context.palette.ink,
                      ),
                    ),
                    Text(
                      sublabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.palette.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: context.palette.accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BadgePill extends StatelessWidget {
  const _BadgePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: context.palette.tintBlueFaint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.computer_outlined,
            size: 15,
            color: context.palette.accent,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.palette.accent,
            ),
          ),
        ],
      ),
    );
  }
}
