import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../messaging/domain/models/message_thread.dart';

class _Topic {
  const _Topic({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.background,
    required this.color,
    this.messageTopic,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color background;
  final Color color;

  /// The conversation topic this opens; null lets the person choose.
  final MessageTopic? messageTopic;
}

const _topics = [
  _Topic(
    icon: Icons.calendar_month_outlined,
    title: 'Appointments',
    subtitle: 'Booking, changing or cancelling appointments.',
    background: Color(0xFFEDF9F0),
    color: AppColors.greenStrong,
    messageTopic: MessageTopic.bookingPayments,
  ),
  _Topic(
    icon: Icons.credit_card,
    title: 'Payments and refunds',
    subtitle: 'Payments, refunds and billing questions.',
    background: Color(0xFFEDF7FF),
    color: AppColors.blue,
    messageTopic: MessageTopic.bookingPayments,
  ),
  _Topic(
    icon: Icons.health_and_safety_outlined,
    title: 'Access and benefits',
    subtitle: 'Membership, eligibility and what’s included.',
    background: Color(0xFFEDF9F0),
    color: AppColors.greenStrong,
    messageTopic: MessageTopic.bookingPayments,
  ),
  _Topic(
    icon: Icons.person_outline,
    title: 'Account and privacy',
    subtitle: 'Your account, personal data and security.',
    background: Color(0xFFEDF7FF),
    color: AppColors.blue,
  ),
];

/// Help and support, under the Profile tab.
class HelpCentreScreen extends StatelessWidget {
  const HelpCentreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const AppHeaderBar(
              showBack: true,
              backFallback: RoutePaths.profile,
            ),
            const SizedBox(height: 20),
            const ScreenTitle(
              title: 'Help and support',
              subtitle:
                  'Choose what you need help with and message our care team.',
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
                onTap: () => context.push(RoutePaths.newMessage),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: context.palette.elevated.withValues(
                            alpha: 0.18,
                          ),
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
                                fontWeight: FontWeight.w600,
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
                color: context.palette.tintRed,
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
                        decoration: BoxDecoration(
                          color: context.palette.tintRedStrong,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.emergency_outlined,
                          color: context.palette.danger,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Urgent or emergency help',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: context.palette.danger,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'If there is immediate danger, contact local '
                              'emergency services.',
                              style: TextStyle(
                                fontSize: 13,
                                color: context.palette.inkMuted,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            InkWell(
                              onTap: () => context.push(RoutePaths.emergency),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'View emergency guidance',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: context.palette.accent,
                                    ),
                                  ),
                                  SizedBox(width: 2),
                                  Icon(
                                    Icons.chevron_right,
                                    size: 16,
                                    color: context.palette.accent,
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
                  Divider(color: context.palette.tintRedLine, height: 1),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Messages are not monitored continuously.',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.palette.inkMuted,
                    ),
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
      color: context.palette.adapt(topic.background),
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: () =>
            context.push(RoutePaths.newMessage, extra: topic.messageTopic),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.palette.elevated,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  topic.icon,
                  color: context.palette.adapt(topic.color),
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: context.palette.ink,
                      ),
                    ),
                    Text(
                      topic.subtitle,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: context.palette.inkMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: context.palette.accent),
            ],
          ),
        ),
      ),
    );
  }
}
