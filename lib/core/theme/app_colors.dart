import 'package:flutter/material.dart';

/// The LifeCome Live brand palette. [blue], [greenStrong], [ink],
/// [inkMuted], [surface] and [line] follow the LifeCome Live complete screen
/// pack (its app.css tokens); [lime], [cyan], [green] and [gold] are the
/// logo's own colours. Values are exact;
/// [lime], [cyan] and [gold] do not carry enough contrast for text on a
/// white background, so they are used for fills, chips and accents, never
/// for body text or small labels.
///
/// These are the brand constants, written for a light page. Anything that has
/// to look right in dark mode too — text, icons, backgrounds, borders, tinted
/// panels — reads its colour from `context.palette` (`AppPalette`) instead;
/// only fills with white content on top (a blue button, a green badge) use
/// these directly.
abstract final class AppColors {
  static const lime = Color(0xFFA2E10D);
  static const cyan = Color(0xFF3DE5F8);
  static const green = Color(0xFF45AF03);
  static const blue = Color(0xFF0068F5);
  static const gold = Color(0xFFB58A35);
  static const white = Color(0xFFFFFFFF);

  /// Hover and pressed state for filled blue buttons.
  static const blueStrong = Color(0xFF0052C4);

  /// An accessible green used for text and icons (plain [green] is a little
  /// light for small text).
  static const greenStrong = Color(0xFF128B36);

  static const ink = Color(0xFF111534);
  static const inkMuted = Color(0xFF66708A);
  static const surface = Color(0xFFF8FAFC);
  static const line = Color(0xFFE5EAF2);

  static const error = Color(0xFFC2261D);
}
