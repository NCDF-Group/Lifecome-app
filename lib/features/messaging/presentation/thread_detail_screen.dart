import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/feedback/error_state.dart';
import '../../../core/widgets/feedback/loading_indicator.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../application/messaging_controller.dart';
import '../domain/models/message_thread.dart';
import 'widgets/message_bubble.dart';
import 'widgets/message_composer.dart';

/// How often an open conversation looks for the care team's replies.
const _pollEvery = Duration(seconds: 10);

/// One conversation with the care team: its messages, oldest at the top, and
/// the box to write the next one.
class ThreadDetailScreen extends ConsumerStatefulWidget {
  const ThreadDetailScreen({super.key, required this.threadId});

  final String threadId;

  @override
  ConsumerState<ThreadDetailScreen> createState() => _ThreadDetailScreenState();
}

class _ThreadDetailScreenState extends ConsumerState<ThreadDetailScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_pollEvery, (_) {
      ref.read(threadMessagesProvider(widget.threadId).notifier).poll();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(threadMessagesProvider(widget.threadId));
    final thread = ref
        .watch(threadsProvider)
        .value
        ?.where((item) => item.id == widget.threadId)
        .firstOrNull;

    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppHeaderBar(
                    showBack: true,
                    showBell: false,
                    backFallback: RoutePaths.messages,
                  ),
                  const SizedBox(height: 4),
                  ScreenTitle(
                    title: thread?.title ?? 'Care team',
                    subtitle: 'Replies usually arrive during service hours.',
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: context.palette.line),
            Expanded(
              child: messages.when(
                loading: () => const LoadingIndicator(),
                error: (error, _) => messages.hasValue
                    ? _list(messages.requireValue)
                    : ErrorState(
                        error: error,
                        onRetry: () => ref.invalidate(
                          threadMessagesProvider(widget.threadId),
                        ),
                      ),
                data: _list,
              ),
            ),
            MessageComposer(
              onSend: (body) => ref
                  .read(threadMessagesProvider(widget.threadId).notifier)
                  .send(body),
            ),
          ],
        ),
      ),
    );
  }

  Widget _list(List<ThreadMessage> messages) {
    // Newest at the bottom, and the view stays pinned there: the list is
    // built upside down (newest first) and shown reversed.
    final children = <Widget>[];
    DateTime? day;
    for (final message in messages) {
      final uk = Formatters.ukTime(message.sentAt);
      final messageDay = DateTime(uk.year, uk.month, uk.day);
      if (day != messageDay) {
        day = messageDay;
        children.add(_DayLabel(day: messageDay));
      }
      children.add(MessageBubble(message: message));
    }
    return ListView(
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: children.reversed.toList(),
    );
  }
}

class _DayLabel extends StatelessWidget {
  const _DayLabel({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Text(
          Formatters.dayLabel(day),
          style: TextStyle(fontSize: 12, color: context.palette.inkMuted),
        ),
      ),
    );
  }
}
