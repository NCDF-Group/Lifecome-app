import 'package:flutter/material.dart';

import 'app_colors.dart';

/// The colours the UI draws with, resolved for the current theme. Read it
/// with `context.palette` — never reach for [AppColors] for anything that has
/// to look right in both light and dark mode.
///
/// [light] reproduces the original brand palette exactly. [dark] is a deep
/// navy counterpart built on the same hues: neutrals invert, accents get a
/// lighter shade (so blue/green/red text and icons stay readable on a dark
/// page), and the pastel tints become dark, desaturated panels.
///
/// Brand colours used as *fills* with white content on top ([AppColors.blue]
/// buttons, [AppColors.greenStrong] badges, ...) don't change between themes,
/// so those keep using [AppColors] directly.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.isDark,
    required this.background,
    required this.surface,
    required this.elevated,
    required this.line,
    required this.ink,
    required this.inkMuted,
    required this.accent,
    required this.positive,
    required this.danger,
    required this.warning,
    required this.amber,
    required this.tintBlue,
    required this.tintBlueFaint,
    required this.tintBlueStrong,
    required this.tintBlueLine,
    required this.tintGreen,
    required this.tintGreenFaint,
    required this.tintGreenStrong,
    required this.tintGreenLine,
    required this.tintRed,
    required this.tintRedStrong,
    required this.tintRedLine,
    required this.tintAmber,
    required this.logoAsset,
  });

  final bool isDark;

  /// The page behind everything.
  final Color background;

  /// A quiet panel on the page: chips, the nav bar, the header's country pill.
  final Color surface;

  /// A card, avatar or row sitting on top of [background], [surface] or one
  /// of the tints.
  final Color elevated;

  /// Hairlines and outlines.
  final Color line;

  /// Primary text and icons.
  final Color ink;

  /// Secondary text and icons.
  final Color inkMuted;

  /// Brand blue as text, an icon or an outline (use [AppColors.blue] itself
  /// for fills).
  final Color accent;

  /// Green as text or an icon.
  final Color positive;

  /// Red as text or an icon.
  final Color danger;

  /// Gold as an icon or accent.
  final Color warning;

  /// Amber text on [tintAmber] (e.g. "Awaiting review").
  final Color amber;

  /// Tinted panels. `tint<Hue>` is the standard panel; `Faint` is a lighter
  /// variant, `Strong` a deeper one for icon wells and badges on a panel, and
  /// `Line` a divider or border on a panel.
  final Color tintBlue;
  final Color tintBlueFaint;
  final Color tintBlueStrong;
  final Color tintBlueLine;
  final Color tintGreen;
  final Color tintGreenFaint;
  final Color tintGreenStrong;
  final Color tintGreenLine;
  final Color tintRed;
  final Color tintRedStrong;
  final Color tintRedLine;
  final Color tintAmber;

  /// The full-colour logo suits a light page; on a dark page the wordmark's
  /// brand blue loses contrast, so dark mode uses the white version.
  final String logoAsset;

  static const light = AppPalette(
    isDark: false,
    background: AppColors.white,
    surface: AppColors.surface,
    elevated: AppColors.white,
    line: AppColors.line,
    ink: AppColors.ink,
    inkMuted: AppColors.inkMuted,
    accent: AppColors.blue,
    positive: AppColors.greenStrong,
    danger: AppColors.error,
    warning: AppColors.gold,
    amber: Color(0xFFB2690A),
    tintBlue: Color(0xFFE3EEFB),
    tintBlueFaint: Color(0xFFE8F4FC),
    tintBlueStrong: Color(0xFFDCEEFA),
    tintBlueLine: Color(0xFFCBDFF3),
    tintGreen: Color(0xFFEAF7E8),
    tintGreenFaint: Color(0xFFE6F6E2),
    tintGreenStrong: Color(0xFFD7F0D2),
    tintGreenLine: Color(0xFFCBE6C6),
    tintRed: Color(0xFFFCEAEA),
    tintRedStrong: Color(0xFFF7D7D4),
    tintRedLine: Color(0xFFF2CFCB),
    tintAmber: Color(0xFFFBEBD4),
    logoAsset: 'assets/images/logo/lifecome-live-logo.svg',
  );

  static const dark = AppPalette(
    isDark: true,
    background: Color(0xFF0B1622),
    surface: Color(0xFF122231),
    elevated: Color(0xFF1A2E42),
    line: Color(0xFF29405A),
    ink: Color(0xFFE8EFF6),
    inkMuted: Color(0xFFA3B5C7),
    accent: Color(0xFF5BA8F0),
    positive: Color(0xFF86D668),
    danger: Color(0xFFFF8F87),
    warning: Color(0xFFE0B35A),
    amber: Color(0xFFF0B45F),
    tintBlue: Color(0xFF152C47),
    tintBlueFaint: Color(0xFF122840),
    tintBlueStrong: Color(0xFF1D3B5E),
    tintBlueLine: Color(0xFF2B4B72),
    tintGreen: Color(0xFF17301E),
    tintGreenFaint: Color(0xFF142B1B),
    tintGreenStrong: Color(0xFF214329),
    tintGreenLine: Color(0xFF30593A),
    tintRed: Color(0xFF3A2024),
    tintRedStrong: Color(0xFF4A282D),
    tintRedLine: Color(0xFF5E3439),
    tintAmber: Color(0xFF3A2D15),
    logoAsset: 'assets/images/logo/lifecome-live-logo-white.svg',
  );

  /// Maps a colour written for light mode — the values screens and const data
  /// tables were designed with — to this palette's equivalent. Colours that
  /// aren't part of the design system pass through unchanged, and in light
  /// mode every colour does. Use it where a colour travels through a const
  /// table or a constructor parameter and so can't be read from the context.
  Color adapt(Color color) {
    if (!isDark) return color;
    return _darkEquivalent[color.toARGB32()] ?? color;
  }

  static final Map<int, Color> _darkEquivalent = {
    for (final (from, to) in <(Color, Color)>[
      (light.ink, dark.ink),
      (light.inkMuted, dark.inkMuted),
      (light.surface, dark.surface),
      (light.line, dark.line),
      (light.accent, dark.accent),
      (light.positive, dark.positive),
      (light.danger, dark.danger),
      (light.warning, dark.warning),
      (light.amber, dark.amber),
      (light.tintBlue, dark.tintBlue),
      (light.tintBlueFaint, dark.tintBlueFaint),
      (light.tintBlueStrong, dark.tintBlueStrong),
      (light.tintBlueLine, dark.tintBlueLine),
      (light.tintGreen, dark.tintGreen),
      (light.tintGreenFaint, dark.tintGreenFaint),
      (light.tintGreenStrong, dark.tintGreenStrong),
      (light.tintGreenLine, dark.tintGreenLine),
      (light.tintRed, dark.tintRed),
      (light.tintRedStrong, dark.tintRedStrong),
      (light.tintRedLine, dark.tintRedLine),
      (light.tintAmber, dark.tintAmber),
      // The welcome screen's decorative blob: a green a shade off the palette's
      // own, kept exact in light mode and mapped to the dark green tint here.
      (Color(0xFFDCF3D6), dark.tintGreenStrong),
      // Placeholder avatar disc and silhouette (find a doctor).
      (Color(0xFFD9E3EC), Color(0xFF2B4259)),
      (Color(0xFF8AA0B4), Color(0xFF9DB3C8)),
    ])
      from.toARGB32(): to,
  };

  @override
  AppPalette copyWith({
    bool? isDark,
    Color? background,
    Color? surface,
    Color? elevated,
    Color? line,
    Color? ink,
    Color? inkMuted,
    Color? accent,
    Color? positive,
    Color? danger,
    Color? warning,
    Color? amber,
    Color? tintBlue,
    Color? tintBlueFaint,
    Color? tintBlueStrong,
    Color? tintBlueLine,
    Color? tintGreen,
    Color? tintGreenFaint,
    Color? tintGreenStrong,
    Color? tintGreenLine,
    Color? tintRed,
    Color? tintRedStrong,
    Color? tintRedLine,
    Color? tintAmber,
    String? logoAsset,
  }) {
    return AppPalette(
      isDark: isDark ?? this.isDark,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      elevated: elevated ?? this.elevated,
      line: line ?? this.line,
      ink: ink ?? this.ink,
      inkMuted: inkMuted ?? this.inkMuted,
      accent: accent ?? this.accent,
      positive: positive ?? this.positive,
      danger: danger ?? this.danger,
      warning: warning ?? this.warning,
      amber: amber ?? this.amber,
      tintBlue: tintBlue ?? this.tintBlue,
      tintBlueFaint: tintBlueFaint ?? this.tintBlueFaint,
      tintBlueStrong: tintBlueStrong ?? this.tintBlueStrong,
      tintBlueLine: tintBlueLine ?? this.tintBlueLine,
      tintGreen: tintGreen ?? this.tintGreen,
      tintGreenFaint: tintGreenFaint ?? this.tintGreenFaint,
      tintGreenStrong: tintGreenStrong ?? this.tintGreenStrong,
      tintGreenLine: tintGreenLine ?? this.tintGreenLine,
      tintRed: tintRed ?? this.tintRed,
      tintRedStrong: tintRedStrong ?? this.tintRedStrong,
      tintRedLine: tintRedLine ?? this.tintRedLine,
      tintAmber: tintAmber ?? this.tintAmber,
      logoAsset: logoAsset ?? this.logoAsset,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    // Non-colour fields can't be blended; switch at the halfway point.
    final nearer = t < 0.5 ? this : other;
    return AppPalette(
      isDark: nearer.isDark,
      background: mix(background, other.background),
      surface: mix(surface, other.surface),
      elevated: mix(elevated, other.elevated),
      line: mix(line, other.line),
      ink: mix(ink, other.ink),
      inkMuted: mix(inkMuted, other.inkMuted),
      accent: mix(accent, other.accent),
      positive: mix(positive, other.positive),
      danger: mix(danger, other.danger),
      warning: mix(warning, other.warning),
      amber: mix(amber, other.amber),
      tintBlue: mix(tintBlue, other.tintBlue),
      tintBlueFaint: mix(tintBlueFaint, other.tintBlueFaint),
      tintBlueStrong: mix(tintBlueStrong, other.tintBlueStrong),
      tintBlueLine: mix(tintBlueLine, other.tintBlueLine),
      tintGreen: mix(tintGreen, other.tintGreen),
      tintGreenFaint: mix(tintGreenFaint, other.tintGreenFaint),
      tintGreenStrong: mix(tintGreenStrong, other.tintGreenStrong),
      tintGreenLine: mix(tintGreenLine, other.tintGreenLine),
      tintRed: mix(tintRed, other.tintRed),
      tintRedStrong: mix(tintRedStrong, other.tintRedStrong),
      tintRedLine: mix(tintRedLine, other.tintRedLine),
      tintAmber: mix(tintAmber, other.tintAmber),
      logoAsset: nearer.logoAsset,
    );
  }
}

/// `context.palette` — the palette of the theme in effect at this point of
/// the tree. Falls back to [AppPalette.light] when there is none (a bare
/// `MaterialApp` in a test, say), so a widget never crashes for lack of one.
extension AppPaletteContext on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}
