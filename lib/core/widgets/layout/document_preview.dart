import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';

/// A record or letter shown as a document on the page (the screen pack's
/// `.document-preview`): a title, a hairline, then the text as written.
class DocumentPreview extends StatelessWidget {
  const DocumentPreview({
    super.key,
    required this.title,
    required this.body,
    this.meta,
  });

  final String title;
  final String body;

  /// A small line under the title, e.g. who wrote it and when.
  final String? meta;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 17),
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 25),
      decoration: BoxDecoration(
        color: palette.elevated,
        border: Border.all(color: palette.line),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: palette.ink.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: palette.ink,
            ),
          ),
          if (meta != null) ...[
            const SizedBox(height: 4),
            Text(
              meta!,
              style: TextStyle(fontSize: 12, color: palette.inkMuted),
            ),
          ],
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: 17),
            color: palette.line,
          ),
          SelectableText(
            body,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.8,
              color: palette.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}
