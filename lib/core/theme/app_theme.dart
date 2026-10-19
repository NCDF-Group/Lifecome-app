import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_palette.dart';
import 'app_radius.dart';
import 'app_typography.dart';

/// The app's theme for one brightness. [Brightness.light] is the original
/// LifeCome Live look, unchanged; [Brightness.dark] is its dark counterpart.
/// Both carry their [AppPalette] as a theme extension — read it with
/// `context.palette` — and which one is shown follows the phone's setting
/// unless the user picked one (see `themeModeProvider`).
ThemeData buildAppTheme({Brightness brightness = Brightness.light}) {
  final dark = brightness == Brightness.dark;
  final palette = dark ? AppPalette.dark : AppPalette.light;

  final base = ThemeData(
    useMaterial3: true,
    fontFamily: appFontFamily,
    colorScheme: dark
        ? ColorScheme.fromSeed(
            seedColor: AppColors.blue,
            brightness: Brightness.dark,
            primary: palette.accent,
            onPrimary: palette.background,
            secondary: AppColors.green,
            surface: palette.background,
            onSurface: palette.ink,
            onSurfaceVariant: palette.inkMuted,
            outline: palette.line,
            outlineVariant: palette.line,
            error: palette.danger,
          )
        : ColorScheme.fromSeed(
            seedColor: AppColors.blue,
            brightness: Brightness.light,
            primary: AppColors.blue,
            secondary: AppColors.green,
            surface: AppColors.white,
            error: AppColors.error,
          ),
    scaffoldBackgroundColor: palette.background,
    extensions: [palette],
  );

  return base.copyWith(
    textTheme: buildAppTextTheme(base.textTheme, color: palette.ink),
    appBarTheme: AppBarTheme(
      backgroundColor: palette.background,
      foregroundColor: palette.ink,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: palette.elevated,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        borderSide: BorderSide(color: palette.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        borderSide: BorderSide(color: palette.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        borderSide: BorderSide(color: palette.accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        borderSide: BorderSide(color: palette.danger, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        borderSide: BorderSide(color: palette.danger, width: 2),
      ),
      hintStyle: TextStyle(color: palette.inkMuted),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.blue
            : palette.elevated,
      ),
      side: BorderSide(color: palette.line, width: 1.5),
    ),
    // Light mode keeps Material's own defaults for these; dark mode needs them
    // pinned to the palette so nothing falls back to a light-theme colour.
    dividerTheme: dark ? DividerThemeData(color: palette.line) : null,
    iconTheme: dark ? IconThemeData(color: palette.ink) : null,
    splashFactory: InkRipple.splashFactory,
  );
}
