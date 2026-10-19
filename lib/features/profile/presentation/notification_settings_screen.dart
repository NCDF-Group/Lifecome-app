import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/preferences/device_preferences.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/inputs/toggle_row.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/screen_title.dart';

/// "Stay informed" (screen pack 029): which updates the person wants. Saved
/// on this device until the backend can store notification preferences.
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(devicePreferencesProvider);
    final notifier = ref.read(devicePreferencesProvider.notifier);

    Widget toggle(String key, String title, String subtitle) => ToggleRow(
      title: title,
      subtitle: subtitle,
      value: prefs[key]!,
      onChanged: (value) => notifier.set(key, value),
    );

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
              title: 'Stay informed',
              subtitle: 'Choose the updates you want to receive.',
            ),
            const SizedBox(height: 8),
            toggle(
              DevicePreferences.appointmentReminders,
              'Appointment reminders',
              'Reminders for GP, care and wellbeing visits.',
            ),
            toggle(
              DevicePreferences.teamMessages,
              'Messages from your team',
              'Know when you receive a new message.',
            ),
            toggle(
              DevicePreferences.orderUpdates,
              'Order updates',
              'Delivery and shop order progress.',
            ),
            toggle(
              DevicePreferences.policyUpdates,
              'Policy updates',
              'Insurance documents and renewals.',
            ),
            const SizedBox(height: 16),
            const InfoBanner(
              message:
                  'Your choices are saved on this phone. To stop all '
                  "notifications, turn them off in your phone's settings.",
            ),
          ],
        ),
      ),
    );
  }
}
