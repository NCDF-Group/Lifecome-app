import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/preferences/device_preferences.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/inputs/toggle_row.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/screen_title.dart';

/// "Make it yours" (screen pack 036): larger text and reduced motion, which
/// take effect straight away across the app and are remembered on this
/// device.
class AccessibilityScreen extends ConsumerWidget {
  const AccessibilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(devicePreferencesProvider);
    final notifier = ref.read(devicePreferencesProvider.notifier);

    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 25),
          children: [
            const AppHeaderBar(
              showBack: true,
              backFallback: RoutePaths.profile,
            ),
            const SizedBox(height: 4),
            const ScreenTitle(
              title: 'Make it yours',
              subtitle: 'Adjust the app to suit your needs.',
            ),
            const SizedBox(height: 8),
            ToggleRow(
              title: 'Larger text',
              subtitle: 'Increase the text size within the app.',
              value: prefs[DevicePreferences.largerText]!,
              onChanged: (v) => notifier.set(DevicePreferences.largerText, v),
            ),
            ToggleRow(
              title: 'Reduce motion',
              subtitle: 'Limit animations and moving effects.',
              value: prefs[DevicePreferences.reduceMotion]!,
              onChanged: (v) => notifier.set(DevicePreferences.reduceMotion, v),
            ),
            const SizedBox(height: 16),
            const InfoBanner(
              message:
                  "Changes apply straight away and are saved on this phone. "
                  "The app also follows your phone's own text size and "
                  'motion settings.',
            ),
          ],
        ),
      ),
    );
  }
}
