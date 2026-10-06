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

  void _open(BuildContext context, WidgetRef ref, NotificationItem item) {
    ref.read(notificationsProvider.notifier).markRead(item.id);
    switch (item.kind) {
      case NotificationKind.booking:
        context.push(RoutePaths.visits);
      case NotificationKind.record:
        context.go(RoutePaths.healthRecords);
      case NotificationKind.message || NotificationKind.support:
        context.go(RoutePaths.messages);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
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
                    icon: const AppSvgIcon(
                      AppSvgGlyph.backLine,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Expanded(
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
                    onPressed: items.isEmpty
                        ? null
                        : ref.read(notificationsProvider.notifier).markAllRead,
                    icon: const AppSvgIcon(
                      AppSvgGlyph.checkLine,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? const _EmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 36),
                      itemBuilder: (context, index) => NotificationTile(
                        item: items[index],
                        onAction: () => _open(context, ref, items[index]),
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
    return const Center(
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
