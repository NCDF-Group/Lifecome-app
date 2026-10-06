import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/profile/application/avatar_controller.dart';

/// The signed-in patient's round profile photo, or the default avatar until they upload one.
class UserAvatar extends ConsumerWidget {
  const UserAvatar({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bytes = ref.watch(avatarProvider).value;
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: bytes == null
            ? Image.asset('assets/images/home/avatar.png', fit: BoxFit.cover)
            : Image.memory(
                bytes,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                cacheWidth: (size * 3).round(),
              ),
      ),
    );
  }
}
