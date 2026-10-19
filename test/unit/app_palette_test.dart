import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifecome_mobile/core/theme/app_colors.dart';
import 'package:lifecome_mobile/core/theme/app_palette.dart';

/// WCAG contrast ratio between two opaque colours.
double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  group('AppPalette.light', () {
    test('uses the screen pack tokens exactly', () {
      const p = AppPalette.light;
      expect(p.isDark, isFalse);
      expect(p.background, AppColors.white);
      expect(p.elevated, AppColors.white);
      expect(p.surface, AppColors.surface);
      expect(p.line, AppColors.line);
      expect(p.ink, AppColors.ink);
      expect(p.inkMuted, AppColors.inkMuted);
      expect(p.accent, AppColors.blue);
      expect(p.positive, AppColors.greenStrong);
      expect(p.danger, AppColors.error);
      expect(p.warning, AppColors.gold);
      expect(p.tintBlue, const Color(0xFFEDF7FF));
      expect(p.tintGreen, const Color(0xFFEDF9F0));
      expect(p.tintRed, const Color(0xFFFCEAEA));
      expect(p.tintAmber, const Color(0xFFFFF1D5));
    });

    test('uses the full-colour logo', () {
      expect(
        AppPalette.light.logoAsset,
        'assets/images/logo/lifecome-health-logo.png',
      );
    });
  });

  group('AppPalette.dark', () {
    const p = AppPalette.dark;

    test('uses the white logo, which stays legible on a dark page', () {
      expect(p.isDark, isTrue);
      expect(p.logoAsset, 'assets/images/logo/lifecome-health-logo-white.png');
    });

    test(
      'every text and icon colour is readable (WCAG AA) on every surface',
      () {
        final surfaces = {
          'background': p.background,
          'surface': p.surface,
          'elevated': p.elevated,
          'tintBlue': p.tintBlue,
          'tintGreen': p.tintGreen,
          'tintRed': p.tintRed,
        };
        final foregrounds = {
          'ink': p.ink,
          'inkMuted': p.inkMuted,
          'accent': p.accent,
          'positive': p.positive,
          'danger': p.danger,
          'warning': p.warning,
        };
        for (final fg in foregrounds.entries) {
          for (final bg in surfaces.entries) {
            expect(
              _contrast(fg.value, bg.value),
              greaterThanOrEqualTo(4.5),
              reason: '${fg.key} on ${bg.key}',
            );
          }
        }
        expect(_contrast(p.amber, p.tintAmber), greaterThanOrEqualTo(4.5));
      },
    );

    test('keeps body text well above the minimum', () {
      expect(_contrast(p.ink, p.background), greaterThanOrEqualTo(7));
      expect(_contrast(p.inkMuted, p.background), greaterThanOrEqualTo(7));
    });

    test('is a different palette from light in every neutral', () {
      const l = AppPalette.light;
      for (final pair in [
        (p.background, l.background),
        (p.surface, l.surface),
        (p.elevated, l.elevated),
        (p.line, l.line),
        (p.ink, l.ink),
        (p.inkMuted, l.inkMuted),
      ]) {
        expect(pair.$1, isNot(pair.$2));
      }
    });
  });

  group('adapt', () {
    test('is the identity in light mode, for any colour', () {
      const unrelated = Color(0xFF123456);
      expect(AppPalette.light.adapt(unrelated), unrelated);
      expect(AppPalette.light.adapt(AppColors.blue), AppColors.blue);
      expect(
        AppPalette.light.adapt(const Color(0xFFEDF7FF)),
        const Color(0xFFEDF7FF),
      );
    });

    test('maps light-mode design colours to their dark equivalents', () {
      const d = AppPalette.dark;
      expect(d.adapt(AppColors.blue), d.accent);
      expect(d.adapt(AppColors.greenStrong), d.positive);
      expect(d.adapt(AppColors.error), d.danger);
      expect(d.adapt(const Color(0xFFEDF7FF)), d.tintBlue);
      expect(d.adapt(const Color(0xFFEDF9F0)), d.tintGreen);
      expect(d.adapt(const Color(0xFFFCEAEA)), d.tintRed);
      expect(d.adapt(const Color(0xFFFFF1D5)), d.tintAmber);
    });

    test('passes colours outside the design system through unchanged', () {
      const unrelated = Color(0xFF123456);
      expect(AppPalette.dark.adapt(unrelated), unrelated);
    });
  });

  test('lerp blends colours and switches the logo at the halfway point', () {
    final mid = AppPalette.light.lerp(AppPalette.dark, 0.5);
    expect(
      mid.background,
      Color.lerp(AppPalette.light.background, AppPalette.dark.background, 0.5),
    );
    expect(
      AppPalette.light.lerp(AppPalette.dark, 0.2).logoAsset,
      AppPalette.light.logoAsset,
    );
    expect(
      AppPalette.light.lerp(AppPalette.dark, 0.8).logoAsset,
      AppPalette.dark.logoAsset,
    );
    expect(AppPalette.light.lerp(null, 0.5), AppPalette.light);
  });
}
