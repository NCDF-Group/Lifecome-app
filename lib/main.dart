import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/providers/core_providers.dart';
import 'core/theme/theme_mode_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Read the saved Appearance choice before the first frame, so nobody sees
  // the wrong theme flash up while it loads.
  final themeMode = await ThemeModeStore().read();

  runApp(
    ProviderScope(
      retry: noAutomaticRetry,
      overrides: [initialThemeModeProvider.overrideWithValue(themeMode)],
      child: const LifeComeLiveApp(),
    ),
  );
}
