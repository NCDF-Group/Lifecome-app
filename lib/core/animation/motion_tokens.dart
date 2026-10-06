import 'package:flutter/animation.dart';

/// Shared durations and curves, so every animated widget in the app moves
/// at the same speed and with the same easing rather than each screen
/// picking its own. Mirrors the website's `--ease-smooth` token
/// (Lifecome-web/src/app/globals.css).
abstract final class MotionTokens {
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 300);
  static const slow = Duration(milliseconds: 500);

  /// The website's `cubic-bezier(0.22, 1, 0.36, 1)`, a smooth deceleration.
  static const easeSmooth = Cubic(0.22, 1, 0.36, 1);
}
