import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remembers the user's Appearance choice between launches. Nothing is stored
/// for [ThemeMode.system], so "follow the phone" is also what a fresh install
/// (or a failed read) gets.
class ThemeModeStore {
  static const _key = 'theme_mode';

  Future<ThemeMode> read() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return switch (prefs.getString(_key)) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
    } catch (_) {
      return ThemeMode.system;
    }
  }

  Future<void> save(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mode == ThemeMode.system) {
        await prefs.remove(_key);
      } else {
        await prefs.setString(_key, mode.name);
      }
    } catch (_) {
      // A cosmetic preference that can't be saved just won't survive a
      // restart; never surface that to the user.
    }
  }
}

final themeModeStoreProvider = Provider<ThemeModeStore>(
  (ref) => ThemeModeStore(),
);

/// The saved choice, read in `main()` before the first frame so a user who
/// picked light or dark never sees the other for an instant. Overridden there;
/// defaults to following the system.
final initialThemeModeProvider = Provider<ThemeMode>((ref) => ThemeMode.system);

/// Which theme the app shows: [ThemeMode.system] (the default) follows the
/// phone's light/dark setting, [ThemeMode.light] and [ThemeMode.dark] pin it.
///
/// The Profile tab's Appearance row calls [set]; anything else that wants to
/// decide the mode — a value delivered by the backend, say — can do the same.
class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ref.watch(initialThemeModeProvider);

  /// Applies [mode] immediately and remembers it for the next launch.
  Future<void> set(ThemeMode mode) async {
    state = mode;
    await ref.read(themeModeStoreProvider).save(mode);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);
