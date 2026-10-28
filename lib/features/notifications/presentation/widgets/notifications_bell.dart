import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/media/lc_icons.dart';
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
        color: context.palette.tintBlue,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push(RoutePaths.notifications),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ExcludeSemantics(
                  child: LcIcon(
                    LcIcons.bell,
                    size: 21,
                    color: context.palette.ink,
                  ),
                ),
                if (unread > 0)
                  Positioned(
                    top: 6,
                    right: 8,
                    child: Container(
                      key: const ValueKey('unread-dot'),
                      width: 9,
                      height: 9,
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
