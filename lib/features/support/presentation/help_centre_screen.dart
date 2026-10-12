import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/layout/app_header_bar.dart';

class _Topic {
  const _Topic({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.background,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color background;
  final Color color;
}

const _topics = [
  _Topic(
    icon: Icons.calendar_month_outlined,
    title: 'Appointments',
    subtitle: 'Booking, changing or cancelling appointments.',
    background: Color(0xFFEAF7E8),
    color: AppColors.greenStrong,
  ),
  _Topic(
    icon: Icons.credit_card,
    title: 'Payments and refunds',
    subtitle: 'Payments, refunds and billing questions.',
    background: Color(0xFFE3EEFB),
    color: AppColors.blue,
  ),
  _Topic(
    icon: Icons.health_and_safety_outlined,
    title: 'Access and benefits',
    subtitle: 'Membership, eligibility and what’s included.',
    background: Color(0xFFEAF7E8),
    color: AppColors.greenStrong,
  ),
  _Topic(
    icon: Icons.person_outline,
    title: 'Account and privacy',
    subtitle: 'Your account, personal data and security.',
    background: Color(0xFFE3EEFB),
    color: AppColors.blue,
  ),
];

/// Help and support, under the Profile tab.
class HelpCentreScreen extends StatelessWidget {
  const HelpCentreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            AppHeaderBar(showBack: true, onBack: () => context.pop()),
            const SizedBox(height: 20),
            const Text(
              'Help and support',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Find answers, or get in touch for more help.',
              style: TextStyle(fontSize: 14, color: AppColors.inkMuted),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search help articles',
                prefixIcon: const Icon(Icons.search, color: AppColors.inkMuted),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final topic in _topics) ...[
              _TopicRow(topic: topic),
              const SizedBox(height: AppSpacing.sm),
            ],
            Material(
              color: AppColors.blue,
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.card),
                onTap: () => context.go(RoutePaths.messages),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.forum_outlined,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Contact patient support',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.white,
                              ),
                            ),
                            Text(
                              'Get help from our care team.',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.white),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFFFCEAEA),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF7D7D4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.emergency_outlined,
                          color: AppColors.error,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Urgent or emergency help',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.error,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'If there is immediate danger, contact local '
                              'emergency services.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.inkMuted,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            InkWell(
                              onTap: () => showComingSoonPopup(
                                context,
                                feature: 'Urgent-care options',
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'View local urgent-care options',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.blue,
                                    ),
                                  ),
                                  SizedBox(width: 2),
                                  Icon(
                                    Icons.chevron_right,
                                    size: 16,
                                    color: AppColors.blue,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Divider(color: Color(0xFFF2CFCB), height: 1),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'Messages are not monitored continuously.',
                    style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicRow extends StatelessWidget {
  const _TopicRow({required this.topic});

  final _Topic topic;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: topic.background,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: () => showComingSoonPopup(context, feature: topic.title),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(topic.icon, color: topic.color, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      topic.subtitle,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.inkMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.blue),
            ],
          ),
        ),
      ),
    );
  }
}
