import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/router/safe_back.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/buttons/ghost_button.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/buttons/secondary_button.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/lists/timeline_item.dart';

/// "Let's get you connected" (screen pack 144), from the waiting room.
class ConnectionHelpScreen extends StatelessWidget {
  const ConnectionHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 25),
          children: [
            const AppHeaderBar(showBack: true, backFallback: RoutePaths.visits),
            const SizedBox(height: 4),
            const ScreenTitle(
              title: 'Let’s get you connected',
              subtitle: 'A few things to check before joining.',
            ),
            const SizedBox(height: 6),
            const CheckList(
              items: [
                'Check your Wi-Fi or mobile data',
                'Allow camera and microphone access for LifeCome',
                'Close other apps that are using your camera',
                'Go back to the waiting room and try again',
              ],
            ),
            const SizedBox(height: 10),
            PrimaryButton(
              label: 'Back to the waiting room',
              onPressed: () => context.goBack(fallback: RoutePaths.visits),
            ),
            const SizedBox(height: 10),
            SecondaryButton(
              label: 'Message the care team',
              onPressed: () => context.go(RoutePaths.messages),
            ),
            const SizedBox(height: 4),
            GhostButton(
              label: 'Manage or reschedule',
              onPressed: () => context.go(RoutePaths.visits),
            ),
          ],
        ),
      ),
    );
  }
}
