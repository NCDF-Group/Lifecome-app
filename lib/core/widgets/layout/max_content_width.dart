import 'package:flutter/material.dart';

/// Caps content at a phone-like width and centers it — the flat-background
/// counterpart to [AuthFormCard]'s width constraint, for screens that don't
/// want its card/padding/shadow, just the same "don't stretch edge-to-edge
/// on a tablet" behavior (full-width text fields and buttons look broken at
/// tablet widths otherwise).
class MaxContentWidth extends StatelessWidget {
  const MaxContentWidth({super.key, required this.child, this.maxWidth = 460});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
