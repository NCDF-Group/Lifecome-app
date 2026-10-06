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

  static const ink = Color(0xFF0B2540);
  static const inkMuted = Color(0xFF435A70);
  static const surface = Color(0xFFF4F9FC);
  static const line = Color(0xFFD8E4EE);

  static const error = Color(0xFFC2261D);
}
