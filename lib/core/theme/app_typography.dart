import 'package:flutter/material.dart';

import 'app_colors.dart';

/// The brand typeface, Liberation Sans, bundled from
/// assets/fonts/LiberationSans (see the `fonts:` block in pubspec.yaml).
const appFontFamily = 'Liberation Sans';

/// Headings read ExtraBold; everything else (body, labels, buttons) reads
/// Regular by default so a screen's own explicit weights (a bold title next
/// to a plain-weight subtitle, for instance) aren't overridden by the
/// ambient text style every unstyled `Text` widget inherits.
TextTheme buildAppTextTheme(TextTheme base) {
  TextStyle? heading(TextStyle? s) => s?.copyWith(fontWeight: FontWeight.w800);
  TextStyle? body(TextStyle? s) => s?.copyWith(fontWeight: FontWeight.w400);

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
