import 'package:flutter/material.dart';

import 'app_colors.dart';

/// The brand typeface, Manrope, bundled from assets/fonts/Manrope (see the
/// `fonts:` block in pubspec.yaml).
const appFontFamily = 'Manrope';

/// The app reads bold throughout: headings in ExtraBold and everything else
/// (body, labels, buttons) in Bold.
TextTheme buildAppTextTheme(TextTheme base) {
  TextStyle? heading(TextStyle? s) => s?.copyWith(fontWeight: FontWeight.w800);
  TextStyle? body(TextStyle? s) => s?.copyWith(fontWeight: FontWeight.w700);

  return base
      .copyWith(
        displayLarge: heading(base.displayLarge),
        displayMedium: heading(base.displayMedium),
        displaySmall: heading(base.displaySmall),
        headlineLarge: heading(base.headlineLarge),
        headlineMedium: heading(base.headlineMedium),
        headlineSmall: heading(base.headlineSmall),
        titleLarge: heading(base.titleLarge),
        titleMedium: body(base.titleMedium),
        titleSmall: body(base.titleSmall),
        bodyLarge: body(base.bodyLarge),
        bodyMedium: body(base.bodyMedium),
        bodySmall: body(base.bodySmall),
        labelLarge: body(base.labelLarge),
        labelMedium: body(base.labelMedium),
        labelSmall: body(base.labelSmall),
      )
      .apply(
        fontFamily: appFontFamily,
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      );
}
