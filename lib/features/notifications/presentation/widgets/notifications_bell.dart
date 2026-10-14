import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../application/notifications_controller.dart';

/// The bell in the top bar. The blue dot is there only when the backend says
/// there is something unread; tapping opens the notification centre.
class NotificationsBell extends ConsumerWidget {
  const NotificationsBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(
      notificationsProvider.select((feed) => feed.value?.unreadCount ?? 0),
    );

    return Semantics(
      button: true,
      label: unread > 0 ? 'Notifications, $unread unread' : 'Notifications',
      child: Material(
        color: context.palette.surface,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => context.push(RoutePaths.notifications),
          child: SizedBox(
            width: 38,
            height: 38,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ExcludeSemantics(
                  child: Icon(
                    Icons.notifications_outlined,
                    size: 20,
                    color: context.palette.ink,
                  ),
                ),
                if (unread > 0)
                  Positioned(
                    top: 8,
                    right: 9,
                    child: Container(
                      key: const ValueKey('unread-dot'),
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
