import 'package:flutter/material.dart';

/// The LifeCome Live brand palette, matching the values used on the website
/// (see Lifecome-web/src/app/globals.css and brand/logo). Values are exact;
/// [lime], [cyan] and [gold] do not carry enough contrast for text on a
/// white background, so they are used for fills, chips and accents, never
/// for body text or small labels.
abstract final class AppColors {
  static const lime = Color(0xFFA2E10D);
  static const cyan = Color(0xFF3DE5F8);
  static const green = Color(0xFF45AF03);
  static const blue = Color(0xFF0667B8);
  static const gold = Color(0xFFB58A35);
  static const white = Color(0xFFFFFFFF);

  /// Hover and pressed state for filled blue buttons.
  static const blueStrong = Color(0xFF054E8E);

  /// An accessible green used for text and icons (plain [green] is a little
  /// light for small text).
  static const greenStrong = Color(0xFF2F7D00);

  // ---- Theme-aware colours -------------------------------------------------------------------
  // These switch between the light and dark palettes (see [_Palette]). They are getters, so they can't
  // be used in `const` expressions; the palette in use is set once per frame by `LifeComeLiveApp`
  // (see [useBrightness]) and the whole UI rebuilds when it changes.

  static Color get ink => _p.ink;
  static Color get inkMuted => _p.inkMuted;
  static Color get surface => _p.surface;
  static Color get line => _p.line;

  static const error = Color(0xFFC2261D);

  // Revamped home / notifications / navigation design (sampled from the
  // design screens).

  /// Primary action blue: buttons, the selected nav pill, link text.
  static const actionBlue = Color(0xFF016DC3);

  /// Fill of the soft cards on the home screen.
  static Color get cardFill => _p.cardFill;

  /// Hairline border of cards, chips and the nav bar.
  static Color get cardBorder => _p.cardBorder;

  /// Headings and body text.
  static Color get textPrimary => _p.textPrimary;

  /// Subtitles, captions and inactive icons.
  static Color get textSecondary => _p.textSecondary;

  /// The page background (white in light mode). Not [white], which is pure white for text and icons
  /// sitting on blue, green or red.
  static Color get background => _p.background;

  /// Fill of text fields and other quiet inputs.
  static Color get inputFill => _p.inputFill;

  /// Hairline dividers inside cards.
  static Color get divider => _p.divider;

  /// Pale blue / green / yellow tints behind icon badges and banners.
  static Color get tintBlue => _p.tintBlue;
  static Color get tintGreen => _p.tintGreen;
  static Color get tintYellow => _p.tintYellow;
  static Color get tintYellowBorder => _p.tintYellowBorder;
  static Color get tintYellowStrong => _p.tintYellowStrong;
  static Color get tintRed => _p.tintRed;
  static Color get tintRedBorder => _p.tintRedBorder;
  static Color get tintGreenSoft => _p.tintGreenSoft;

  /// Headings shown in an even deeper tone than [textPrimary] ("Quick Links").
  static Color get heading => _p.heading;

  /// Text and icons on a green / success background.
  static Color get successText => _p.successText;
  static Color get warningText => _p.warningText;

  /// Cards that hold a fixed light illustration (Online GP, Smart GP Clinic): the artwork has its own
  /// pale background baked in, so these stay light in dark mode too.
  static const illustrationFill = Color(0xFFF5F9FD);
  static const onIllustration = Color(0xFF24262D);
  static const onIllustrationMuted = Color(0xFF667085);

  /// Icon accents of the revamped screens (sampled from the designs).
  static const accentLime = Color(0xFFA2D610);
  static const accentGreen = Color(0xFF49AA02);
  static const accentCyan = Color(0xFF3EE5FE);

  /// Unread dot on bell / chat icons.
  static const alertRed = Color(0xFFD3172A);

  /// The wordmark that reads on the current background (dark text in light mode, white in dark mode).
  static String get logoAsset => brightness == Brightness.dark
      ? 'assets/images/logo/lifecome-live-logo-white.svg'
      : 'assets/images/logo/lifecome-live-logo.svg';

  // ---- Palette switching --------------------------------------------------------------------

  static _Palette _p = _Palette.light;

  /// The brightness the UI is currently drawn in.
  static Brightness get brightness =>
      identical(_p, _Palette.dark) ? Brightness.dark : Brightness.light;

  /// Selects the light or dark palette. Called by the app root before the UI builds.
  static void useBrightness(Brightness brightness) {
    _p = brightness == Brightness.dark ? _Palette.dark : _Palette.light;
  }
}

class _Palette {
  const _Palette({
    required this.ink,
    required this.inkMuted,
    required this.surface,
    required this.line,
    required this.cardFill,
    required this.cardBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.background,
    required this.inputFill,
    required this.divider,
    required this.tintBlue,
    required this.tintGreen,
    required this.tintYellow,
    required this.tintYellowBorder,
    required this.tintYellowStrong,
    required this.tintRed,
    required this.tintRedBorder,
    required this.tintGreenSoft,
    required this.heading,
    required this.successText,
    required this.warningText,
  });

  final Color ink;
  final Color inkMuted;
  final Color surface;
  final Color line;
  final Color cardFill;
  final Color cardBorder;
  final Color textPrimary;
  final Color textSecondary;
  final Color background;
  final Color inputFill;
  final Color divider;
  final Color tintBlue;
  final Color tintGreen;
  final Color tintYellow;
  final Color tintYellowBorder;
  final Color tintYellowStrong;
  final Color tintRed;
  final Color tintRedBorder;
  final Color tintGreenSoft;
  final Color heading;
  final Color successText;
  final Color warningText;

  static const light = _Palette(
    ink: Color(0xFF0B2540),
    inkMuted: Color(0xFF435A70),
    surface: Color(0xFFF4F9FC),
    line: Color(0xFFD8E4EE),
    cardFill: Color(0xFFF5F9FD),
    cardBorder: Color(0xFFD7DAE0),
    textPrimary: Color(0xFF24262D),
    textSecondary: Color(0xFF667085),
    background: Color(0xFFFFFFFF),
    inputFill: Color(0xFFF6F7F9),
    divider: Color(0xFFE7E9ED),
    tintBlue: Color(0xFFD6E6F5),
    tintGreen: Color(0xFFE2F2D6),
    tintYellow: Color(0xFFFFFCEA),
    tintYellowBorder: Color(0xFFFFE346),
    tintYellowStrong: Color(0xFFFFF3C4),
    tintRed: Color(0xFFFEF3F3),
    tintRedBorder: Color(0xFFF3C9CD),
    tintGreenSoft: Color(0xFFEAF7E8),
    heading: Color(0xFF0B101A),
    successText: Color(0xFF1B9C4A),
    warningText: Color(0xFFD9820B),
  );

  static const dark = _Palette(
    ink: Color(0xFFE8EEF4),
    inkMuted: Color(0xFF9FB0C0),
    surface: Color(0xFF161F2A),
    line: Color(0xFF2A3644),
    cardFill: Color(0xFF151E29),
    cardBorder: Color(0xFF2B3744),
    textPrimary: Color(0xFFE9EDF2),
    textSecondary: Color(0xFF98A4B5),
    background: Color(0xFF0D141C),
    inputFill: Color(0xFF18222D),
    divider: Color(0xFF263240),
    tintBlue: Color(0xFF1C3752),
    tintGreen: Color(0xFF1F3A1A),
    tintYellow: Color(0xFF2B2810),
    tintYellowBorder: Color(0xFF6B5E12),
    tintYellowStrong: Color(0xFF3D3512),
    tintRed: Color(0xFF301A1D),
    tintRedBorder: Color(0xFF5C2B31),
    tintGreenSoft: Color(0xFF16301C),
    heading: Color(0xFFF1F4F8),
    successText: Color(0xFF4CC97E),
    warningText: Color(0xFFF0A23A),
  );
}
