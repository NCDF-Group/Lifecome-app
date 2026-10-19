import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/layout/section_header.dart';
import '../../../core/widgets/lists/row_card.dart';
import '../../../core/widgets/media/lc_icons.dart';
import '../../messaging/domain/models/message_thread.dart';

/// A help topic: opens a message to the care team about it.
class _Topic {
  const _Topic({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.messageTopic,
  });

  final String icon;
  final String title;
  final String subtitle;

  /// The conversation topic this opens; null lets the person choose.
  final MessageTopic? messageTopic;
}

const _topics = [
  _Topic(
    icon: LcIcons.calendar,
    title: 'Appointments',
    subtitle: 'Booking, changing or cancelling appointments',
    messageTopic: MessageTopic.onlineAppointment,
  ),
  _Topic(
    icon: LcIcons.card,
    title: 'Payments and refunds',
    subtitle: 'Payments, refunds and billing questions',
    messageTopic: MessageTopic.bookingPayments,
  ),
  _Topic(
    icon: LcIcons.shield,
    title: 'Access and benefits',
    subtitle: 'Membership, eligibility and what’s included',
  ),
  _Topic(
    icon: LcIcons.lock,
    title: 'Account and privacy',
    subtitle: 'Your account, personal data and security',
  ),
];

const _faqs = [
  (
    'How do I change an appointment?',
    'Open Visits, choose the appointment and select Manage. You can cancel it '
        'there, or message the care team to move it.',
  ),
  (
    'Where can I find my care plan?',
    'Open GP from Home, then Your care plan. Records shared with you are in '
        'Health records.',
  ),
  (
    'Can I use my health plan for every service?',
    'Cover depends on your plan and the service you choose. Link your plan '
        'in Membership & benefits to see what it covers before you book.',
  ),
  (
    'Are messages monitored all the time?',
    'No. Messages are reviewed during service hours. If you need help '
        'urgently, use the emergency guidance.',
  ),
];

/// "How can we help?" (screen pack 030): answers to common questions, the
/// topics that start a message to the care team (031), and urgent help.
class HelpCentreScreen extends StatelessWidget {
  const HelpCentreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 25),
          children: [
            const AppHeaderBar(
              showBack: true,
              backFallback: RoutePaths.profile,
            ),
            const SizedBox(height: 4),
            const ScreenTitle(
              title: 'How can we help?',
              subtitle: 'Find answers or contact the right team.',
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: palette.line),
                borderRadius: BorderRadius.circular(17),
              ),
              clipBehavior: Clip.antiAlias,
              child: Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: Column(
                  children: [
                    for (var i = 0; i < _faqs.length; i++) ...[
                      if (i > 0) Divider(height: 1, color: palette.line),
                      ExpansionTile(
                        title: Text(
                          _faqs[i].$1,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: palette.ink,
                          ),
                        ),
                        iconColor: palette.accent,
                        collapsedIconColor: palette.accent,
                        childrenPadding: const EdgeInsets.fromLTRB(
                          16,
                          0,
                          16,
                          14,
                        ),
                        expandedAlignment: Alignment.centerLeft,
                        children: [
                          Text(
                            _faqs[i].$2,
                            style: TextStyle(
                              fontSize: 13.5,
                              height: 1.6,
                              color: palette.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SectionHeader(title: 'Contact support'),
            const SizedBox(height: 4),
            for (final (i, topic) in _topics.indexed)
              RowCard(
                icon: topic.icon,
                title: topic.title,
                subtitle: topic.subtitle,
                tone: i.isEven ? RowCardTone.blue : RowCardTone.mint,
                onTap: () => context.push(
                  RoutePaths.newMessage,
                  extra: topic.messageTopic,
                ),
              ),
            const SizedBox(height: 10),
            const InfoBanner(
              message:
                  'Messages are reviewed during service hours, not '
                  'continuously.',
            ),
            const SizedBox(height: 12),
            RowCard(
              icon: LcIcons.info,
              title: 'View emergency guidance',
              subtitle: 'What to do when you need urgent help',
              tone: RowCardTone.white,
              onTap: () => context.push(RoutePaths.emergency),
            ),
          ],
        ),
      ),
    );
  }
}
