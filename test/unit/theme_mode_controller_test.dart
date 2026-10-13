import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifecome_mobile/core/theme/theme_mode_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('ThemeModeStore', () {
    test('follows the system when nothing has been saved', () async {
      expect(await ThemeModeStore().read(), ThemeMode.system);
    });

    test('remembers light and dark', () async {
      final store = ThemeModeStore();
      await store.save(ThemeMode.dark);
      expect(await store.read(), ThemeMode.dark);
      await store.save(ThemeMode.light);
      expect(await store.read(), ThemeMode.light);
    });

    test('saving system forgets the choice', () async {
      final store = ThemeModeStore();
      await store.save(ThemeMode.dark);
      await store.save(ThemeMode.system);
      expect(await store.read(), ThemeMode.system);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('theme_mode'), isFalse);
    });

    test('treats an unrecognised stored value as system', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'sepia'});
      expect(await ThemeModeStore().read(), ThemeMode.system);
    });
  });

  group('ThemeModeController', () {
    test('starts from the value read at launch', () {
      final container = ProviderContainer(
        overrides: [initialThemeModeProvider.overrideWithValue(ThemeMode.dark)],
      );
      addTearDown(container.dispose);
      expect(container.read(themeModeProvider), ThemeMode.dark);
    });

    test('defaults to following the system', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(themeModeProvider), ThemeMode.system);
    });

    test('set applies the mode immediately and persists it', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(themeModeProvider.notifier).set(ThemeMode.dark);
      expect(container.read(themeModeProvider), ThemeMode.dark);
      expect(await ThemeModeStore().read(), ThemeMode.dark);

      await container.read(themeModeProvider.notifier).set(ThemeMode.system);
      expect(container.read(themeModeProvider), ThemeMode.system);
      expect(await ThemeModeStore().read(), ThemeMode.system);
    });
  });
}
