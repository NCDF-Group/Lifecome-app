import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_svg_icons.dart';
import '../application/notifications_controller.dart';
import '../domain/models/notification_item.dart';
import 'widgets/notification_tile.dart';

/// The notification centre, opened from the bell on Home: a back arrow, a
/// centred title, and a tick that marks everything as read.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  /// Marks the notification read and takes the patient to what it's about.
  void _open(BuildContext context, WidgetRef ref, NotificationItem item) {
    if (item.unread) {
      ref.read(notificationsProvider.notifier).markRead(item.id);
    }
    switch (item.target) {
      case NotificationTarget.booking:
        context.push(RoutePaths.visits);
      case NotificationTarget.records:
        context.go(RoutePaths.healthRecords);
      case NotificationTarget.messages:
        context.go(RoutePaths.messages);
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(notificationsProvider);
    final items = feed.value ?? const <NotificationItem>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: () => context.canPop()
                        ? context.pop()
                        : context.go(RoutePaths.home),
                    icon: AppSvgIcon(
                      AppSvgGlyph.backLine,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Notifications',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Mark all as read',
                    onPressed: items.any((item) => item.unread)
                        ? ref.read(notificationsProvider.notifier).markAllRead
                        : null,
                    icon: AppSvgIcon(
                      AppSvgGlyph.checkLine,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: feed.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: TextButton(
                    onPressed: () => ref.invalidate(notificationsProvider),
                    child: const Text(
                      "Couldn't load notifications. Tap to retry.",
                    ),
                  ),
                ),
                data: (items) => RefreshIndicator(
                  onRefresh: () =>
                      ref.read(notificationsProvider.notifier).refresh(),
                  child: items.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.sizeOf(context).height * 0.6,
                              child: const _EmptyState(),
                            ),
                          ],
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                          itemCount: items.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 36),
                          itemBuilder: (context, index) => NotificationTile(
                            item: items[index],
                            onAction: () => _open(context, ref, items[index]),
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
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 48,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              "You're all caught up",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Visit reminders, test results and messages will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
