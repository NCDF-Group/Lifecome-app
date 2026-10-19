import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';

/// Label / value rows separated by hairlines (the screen pack's
/// `.detail-list`), e.g. an appointment's service, clinician, date and time.
class DetailList extends StatelessWidget {
  const DetailList({super.key, required this.rows});

  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      children: [
        for (var i = 0; i < rows.length; i++)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              border: i == rows.length - 1
                  ? null
                  : Border(bottom: BorderSide(color: palette.line)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rows[i].$1,
                  style: TextStyle(fontSize: 13, color: palette.inkMuted),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    rows[i].$2,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                      color: palette.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// The background of a [PanelCard].
enum PanelTone { neutral, mint, blue }

/// A soft bordered block with a heading and a paragraph (the screen pack's
/// `.panel`). [child] goes under the body when given.
class PanelCard extends StatelessWidget {
  const PanelCard({
    super.key,
    this.title,
    this.body,
    this.tone = PanelTone.neutral,
    this.child,
  });

  final String? title;
  final String? body;
  final PanelTone tone;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final (background, border) = switch (tone) {
      PanelTone.neutral => (palette.surface, palette.line),
      PanelTone.mint => (palette.tintGreen, palette.tintGreenLine),
      PanelTone.blue => (palette.tintBlue, palette.tintBlueLine),
    };
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 7),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Text(
              title!,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: palette.ink,
              ),
            ),
          if (body != null) ...[
            if (title != null) const SizedBox(height: 6),
            Text(
              body!,
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: palette.inkMuted,
              ),
            ),
          ],
          if (child != null) ...[const SizedBox(height: 8), child!],
        ],
      ),
    );
  }
}
