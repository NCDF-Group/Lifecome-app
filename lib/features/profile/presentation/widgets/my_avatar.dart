import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/widgets/media/avatar.dart';
import '../../application/profile_controller.dart';

/// The signed-in person's own avatar: their uploaded photo when they have
/// one, otherwise their real initials. Never a stock face.
class MyAvatar extends ConsumerWidget {
  const MyAvatar({super.key, this.radius = 22, this.fallbackName});

  final double radius;

  /// Shown as initials while the profile is still loading (the name saved at
  /// sign-in), so the avatar is never a blank circle.
  final String? fallbackName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(meProvider).value;
    final profile = me?.profile;
    final api = ref.watch(apiClientProvider);

    ImageProvider? photo;
    final updatedAt = profile?.avatarUpdatedAt;
    if (updatedAt != null) {
      photo = NetworkImage(
        '${api.baseUrl}/me/avatar?v=${updatedAt.millisecondsSinceEpoch}',
        headers: api.authHeaders,
      );
    }

    return UserAvatar(
      name: me?.displayName ?? fallbackName,
      image: photo,
      radius: radius,
    );
  }
}
