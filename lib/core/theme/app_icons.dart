import 'package:flutter/material.dart';

/// A minimalist house silhouette for the Home tab — a plain geometric
/// pentagon (roof + walls, no door/window) in a bold, uniform stroke,
/// styled after the clean home icon several short-video apps use instead of
/// Material's `home` glyph. Reads `IconTheme.of(context)` for color/size so
/// it drops into `NavigationDestination` exactly like a built-in `Icon`
/// would (see `app_theme.dart`'s `navigationBarTheme`).
class HouseNavIcon extends StatelessWidget {
  const HouseNavIcon({super.key, this.filled = false});

  final bool filled;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final color = iconTheme.color ?? const Color(0xFF000000);
    final size = iconTheme.size ?? 24;
    return CustomPaint(
      size: Size(size, size),
      painter: _HousePainter(color: color, filled: filled),
    );
  }
}

class _HousePainter extends CustomPainter {
  _HousePainter({required this.color, required this.filled});

  final Color color;
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.5, h * 0.05)
      ..lineTo(w * 0.95, h * 0.42)
      ..lineTo(w * 0.95, h * 0.93)
      ..lineTo(w * 0.05, h * 0.93)
      ..lineTo(w * 0.05, h * 0.42)
      ..close();

    if (filled) {
      canvas.drawPath(path, Paint()..color = color);
    } else {
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.10
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HousePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.filled != filled;
}
