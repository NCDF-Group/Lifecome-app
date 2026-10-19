import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons/secondary_button.dart';
import '../../../core/widgets/feedback/error_state.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/feedback/loading_indicator.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/lists/row_card.dart';
import '../../../core/widgets/media/lc_icons.dart';
import '../application/messaging_controller.dart';
import '../domain/models/message_thread.dart';

/// The Messages tab ("Your messages", screen pack 014): the person's real
/// conversations with the care team, most recent first, and the way to
/// start another.
class MessageThreadsScreen extends ConsumerWidget {
  const MessageThreadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threads = ref.watch(threadsProvider);
    final notifier = ref.read(threadsProvider.notifier);

    Widget body(List<MessageThread> list) => list.isEmpty
        ? const _EmptyThreads()
        : Column(children: [for (final t in list) _ThreadCard(thread: t)]);

    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: notifier.refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 25),
            children: [
              // A tab root, so the back link goes Home.
              const AppHeaderBar(showBack: true),
              const SizedBox(height: 4),
              const ScreenTitle(
                title: 'Your messages',
                subtitle: 'Stay connected with your care team.',
              ),
              const SizedBox(height: 14),
              threads.when(
                loading: () => const LoadingIndicator(),
                error: (error, _) => threads.hasValue
                    ? body(threads.requireValue)
                    : ErrorState(error: error, onRetry: notifier.refresh),
                data: body,
              ),
              const SizedBox(height: 8),
              SecondaryButton(
                label: 'New message',
                onPressed: () => context.push(RoutePaths.newMessage),
              ),
              const SizedBox(height: 14),
              const InfoBanner(
                message:
                    'Messages are reviewed during service hours and are not '
                    'monitored for emergencies.',
              ),
              const SizedBox(height: 12),
              UrgentHelpLink(onTap: () => context.push(RoutePaths.emergency)),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyThreads extends StatelessWidget {
  const _EmptyThreads();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: context.palette.surface,
        border: Border.all(color: context.palette.line),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LcIcon(LcIcons.message, size: 36, color: context.palette.accent),
            const SizedBox(height: 10),
            Text(
              'No messages yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: context.palette.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Send a message to start a conversation with your care team.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: context.palette.inkMuted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The [LcIcons] for a conversation's topic.
String _topicIcon(MessageTopic? topic) => switch (topic) {
  MessageTopic.bookingPayments => LcIcons.card,
  MessageTopic.onlineAppointment => LcIcons.video,
  MessageTopic.clinicVisit => LcIcons.clinic,
  MessageTopic.followUp => LcIcons.calendar,
  null => LcIcons.message,
};

class _ThreadCard extends StatelessWidget {
  const _ThreadCard({required this.thread});

  final MessageThread thread;

  @override
  Widget build(BuildContext context) {
    return RowCard(
      icon: _topicIcon(thread.topic),
      title: thread.title,
      subtitle: thread.lastMessage ?? 'No messages yet',
      trailing: Text(
        Formatters.relative(thread.updatedAt),
        style: TextStyle(fontSize: 12, color: context.palette.inkMuted),
      ),
      onTap: () => context.push('${RoutePaths.messageThread}/${thread.id}'),
    );
  }
}
