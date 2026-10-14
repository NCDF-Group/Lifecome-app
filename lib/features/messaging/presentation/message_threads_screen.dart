import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/feedback/error_state.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/feedback/loading_indicator.dart';
import '../application/messaging_controller.dart';
import '../domain/models/message_thread.dart';

/// The Messages tab — blueprint view 22, Care Team Messages: the person's
/// real conversations with the care team, most recent first, and the way to
/// start another.
class MessageThreadsScreen extends ConsumerWidget {
  const MessageThreadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threads = ref.watch(threadsProvider);
    final notifier = ref.read(threadsProvider.notifier);

    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  SvgPicture.asset(
                    context.palette.logoAsset,
                    height: 24,
                    semanticsLabel: 'LifeCome Live',
                  ),
                  const Spacer(),
                  Material(
                    color: context.palette.surface,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => context.go(RoutePaths.profile),
                      child: SizedBox(
                        width: 38,
                        height: 38,
                        child: Icon(
                          Icons.person_outline,
                          size: 20,
                          color: context.palette.ink,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Messages',
                    style: TextStyle(
                      fontSize: 13,
                      color: context.palette.inkMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Care team messages',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: context.palette.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Patient support.',
                    style: TextStyle(
                      fontSize: 14,
                      color: context.palette.inkMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const InfoBanner(
                    message:
                        'Messages are reviewed during service hours, not '
                        'continuously.',
                  ),
                ],
              ),
            ),
            Expanded(
              child: threads.when(
                loading: () => const LoadingIndicator(),
                error: (error, _) => threads.hasValue
                    ? _list(context, threads.requireValue, notifier.refresh)
                    : ErrorState(error: error, onRetry: notifier.refresh),
                data: (data) => _list(context, data, notifier.refresh),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: PrimaryButton(
                label: 'New message',
                icon: Icons.edit_outlined,
                onPressed: () => context.push(RoutePaths.newMessage),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Material(
                color: context.palette.tintRed,
                borderRadius: BorderRadius.circular(AppRadius.control),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.control),
                  onTap: () => context.push(RoutePaths.emergency),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.emergency_outlined,
                          size: 18,
                          color: context.palette.danger,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Need urgent help?',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: context.palette.danger,
                                ),
                              ),
                              Text(
                                'View emergency guidance.',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: context.palette.danger.withValues(
                                    alpha: 0.85,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: context.palette.danger,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _list(
    BuildContext context,
    List<MessageThread> threads,
    Future<void> Function() onRefresh,
  ) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: threads.isEmpty
          ? LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: constraints.maxHeight,
                  child: const _EmptyThreads(),
                ),
              ),
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: threads.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
              itemBuilder: (context, index) =>
                  _ThreadCard(thread: threads[index]),
            ),
    );
  }
}

class _EmptyThreads extends StatelessWidget {
  const _EmptyThreads();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: context.palette.tintBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.forum_outlined,
                color: context.palette.accent,
                size: 28,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No messages yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
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

class _ThreadCard extends StatelessWidget {
  const _ThreadCard({required this.thread});

  final MessageThread thread;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: palette.tintBlue,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: () => context.push('${RoutePaths.messageThread}/${thread.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: palette.elevated,
                child: Icon(Icons.support_agent, color: palette.accent),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            thread.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: palette.ink,
                            ),
                          ),
                        ),
                        Text(
                          Formatters.relative(thread.updatedAt),
                          style: TextStyle(
                            fontSize: 11.5,
                            color: palette.inkMuted,
                          ),
                        ),
                      ],
                    ),
                    if (thread.lastMessage != null)
                      Text(
                        thread.lastMessage!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: palette.inkMuted,
                          height: 1.3,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
