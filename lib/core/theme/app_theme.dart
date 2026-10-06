import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_typography.dart';

/// The app's light and dark themes. Colours come from [AppColors], which reads whichever palette is
/// active, so each theme is built with its own palette switched on (and the previous one restored).
ThemeData buildAppTheme([Brightness brightness = Brightness.light]) {
  final previous = AppColors.brightness;
  AppColors.useBrightness(brightness);
  try {
    return _build(brightness);
  } finally {
    AppColors.useBrightness(previous);
  }
}

ThemeData _build(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    fontFamily: appFontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      brightness: brightness,
      primary: dark ? AppColors.actionBlue : AppColors.blue,
      secondary: AppColors.green,
      surface: AppColors.background,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.background,
    canvasColor: AppColors.background,
    dividerColor: AppColors.divider,
  );

  return base.copyWith(
    textTheme: buildAppTextTheme(base.textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.ink,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        borderSide: BorderSide(color: AppColors.line, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        borderSide: BorderSide(color: AppColors.line, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        borderSide: BorderSide(
          color: dark ? AppColors.actionBlue : AppColors.blue,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      hintStyle: TextStyle(color: AppColors.inkMuted),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.blue
            : AppColors.background,
      ),
      side: BorderSide(color: AppColors.line, width: 1.5),
    ),
    dialogTheme: DialogThemeData(backgroundColor: AppColors.background),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
    ),
    splashFactory: InkRipple.splashFactory,
  );
}
