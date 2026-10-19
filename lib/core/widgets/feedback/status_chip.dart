import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';
import '../media/lc_icons.dart';

/// The colour of a [StatusBadge].
enum BadgeTone { green, blue, amber, gray }

/// A small rounded status label such as "Confirmed" or "Completed" (the
/// screen pack's `.badge`).
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.label, {super.key, this.tone = BadgeTone.green});

  final String label;
  final BadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final (background, color) = switch (tone) {
      BadgeTone.green => (palette.tintGreenStrong, palette.positive),
      BadgeTone.blue => (palette.tintBlueStrong, palette.accent),
      BadgeTone.amber => (palette.tintAmber, palette.amber),
      BadgeTone.gray => (palette.surface, palette.inkMuted),
    };
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }
}

/// The large green tick at the top of a confirmation screen (the screen
/// pack's `.success-icon`).
class SuccessIcon extends StatelessWidget {
  const SuccessIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 18, bottom: 20),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: palette.tintGreenStrong,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: LcIcon(LcIcons.check, size: 34, color: palette.positive),
      ),
    );
  }
}
