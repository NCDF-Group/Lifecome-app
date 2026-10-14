import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/widgets/feedback/app_popup.dart';

/// The backend refuses patient actions (booking, messaging, checking cover)
/// until the person has a profile. Says so, and takes them to finish it if
/// they agree.
Future<void> promptCompleteProfile(BuildContext context) async {
  final goOn = await showAppPopup<bool>(
    context,
    kind: AppPopupKind.info,
    title: 'Finish your profile first',
    message:
        'We need a few details about you before you can do this. It only '
        'takes a minute.',
    primaryLabel: 'Complete profile',
    secondaryLabel: 'Not now',
  );
  if (goOn == true && context.mounted) {
    context.push(RoutePaths.completeProfile);
  }
}
