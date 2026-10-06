import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/country/app_country.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/services/session_store.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_svg_icons.dart';
import '../../../../core/widgets/media/user_avatar.dart';
import '../../../../core/widgets/feedback/app_popup.dart';
import '../../../notifications/application/notifications_controller.dart';

/// The greeting row at the top of Home and the first Book screens: avatar,
/// "Hello, {first name}", the user's location (tap to change), and the chat
/// and notification icons.
class HomeHeader extends ConsumerStatefulWidget {
  const HomeHeader({super.key});

  @override
  ConsumerState<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends ConsumerState<HomeHeader> {
  StoredSession? _session;

  @override
  void initState() {
    super.initState();
    ref.read(sessionStoreProvider).read().then((session) {
      if (mounted) setState(() => _session = session);
    });
  }

  String get _firstName {
    final name = _session?.displayName;
    if (name == null || name.isEmpty) return 'there';
    return name.split(' ').first;
  }

  Future<void> _pickCountry() async {
    final picked = await showCountryPickerPopup(
      context,
      current: ref.read(countryProvider),
    );
    if (picked != null) {
      await ref.read(countryProvider.notifier).select(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final country = ref.watch(countryProvider);
    final hasUnread = ref.watch(hasUnreadNotificationsProvider);

    return Row(
      children: [
        const UserAvatar(size: 40),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $_firstName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  color: AppColors.textPrimary,
                ),
              ),
              InkWell(
                onTap: _pickCountry,
                borderRadius: BorderRadius.circular(6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppSvgIcon(
                      AppSvgGlyph.pinLine,
                      size: 17,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        country.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _BadgedIconButton(
          tooltip: 'Messages',
          glyph: AppSvgGlyph.chatLine,
          showDot: false,
          onTap: () => context.go(RoutePaths.messages),
        ),
        const SizedBox(width: 4),
        _BadgedIconButton(
          tooltip: 'Notifications',
          glyph: AppSvgGlyph.bellLine,
          showDot: hasUnread,
          onTap: () => context.push(RoutePaths.notifications),
        ),
      ],
    );
  }
}

class _BadgedIconButton extends StatelessWidget {
  const _BadgedIconButton({
    required this.tooltip,
    required this.glyph,
    required this.showDot,
    required this.onTap,
  });

  final String tooltip;
  final AppSvgGlyph glyph;
  final bool showDot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AppSvgIcon(glyph, size: 28, color: AppColors.textPrimary),
              if (showDot)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.alertRed,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
