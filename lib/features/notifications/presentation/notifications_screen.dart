import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/feedback/empty_state.dart';
import '../../../core/widgets/feedback/error_state.dart';
import '../../../core/widgets/feedback/loading_indicator.dart';
import '../../../core/widgets/layout/back_app_bar.dart';
import '../../../core/widgets/layout/max_content_width.dart';
import '../application/notifications_controller.dart';
import '../domain/models/notification_item.dart';
import 'widgets/notification_tile.dart';

/// The notification centre — visit confirmations, replies from the care team
/// and the like, newest first. Opened from the bell in the top bar.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  void _open(BuildContext context, WidgetRef ref, NotificationItem item) {
    ref.read(notificationsProvider.notifier).markRead(item.id);
    switch (item.target) {
      case NotificationTarget.booking:
        context.go(RoutePaths.visits);
      case NotificationTarget.records:
        context.push(RoutePaths.healthRecords);
      case NotificationTarget.messages:
        context.go(RoutePaths.messages);
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(notificationsProvider);
    final notifier = ref.read(notificationsProvider.notifier);
    final unread = feed.value?.unreadCount ?? 0;

    return Scaffold(
      backgroundColor: context.palette.background,
      appBar: BackAppBar(
        title: 'Notifications',
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: notifier.markAllRead,
              child: Text(
                'Mark all read',
                style: TextStyle(
                  color: context.palette.accent,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: feed.when(
          loading: () => const LoadingIndicator(),
          error: (error, _) => feed.hasValue
              ? _list(context, ref, feed.requireValue)
              : ErrorState(error: error, onRetry: notifier.refresh),
          data: (data) => _list(context, ref, data),
        ),
      ),
    );
  }

  Widget _list(BuildContext context, WidgetRef ref, NotificationFeed feed) {
    final notifier = ref.read(notificationsProvider.notifier);
    return RefreshIndicator(
      onRefresh: notifier.refresh,
      child: feed.items.isEmpty
          ? LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: constraints.maxHeight,
                  child: const EmptyState(
                    icon: Icons.notifications_none,
                    title: "You're all caught up",
                    message:
                        'Booking updates and replies from your care team will '
                        'show up here.',
                  ),
                ),
              ),
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: feed.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final item = feed.items[index];
                return MaxContentWidth(
                  child: NotificationTile(
                    item: item,
                    onOpen: () => _open(context, ref, item),
                  ),
                );
              },
            ),
    );
  }
}
