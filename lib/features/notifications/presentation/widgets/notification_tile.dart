import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/models/notification_item.dart';

/// One entry in the notification feed: an icon for what it is about, the
/// message (with names and dates in bold), the care team's quoted reply when
/// there is one, and a button that opens the thing it is about.
class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.item, required this.onOpen});

  final NotificationItem item;
  final VoidCallback onOpen;

  IconData get _icon => switch (item.kind) {
    NotificationKind.booking => Icons.event_available_outlined,
    NotificationKind.message ||
    NotificationKind.support => Icons.chat_bubble_outline,
    NotificationKind.record => Icons.description_outlined,
    NotificationKind.other => Icons.notifications_none,
  };

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final unread = !item.isRead;

    return Material(
      color: unread ? palette.tintBlue : palette.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: palette.elevated,
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon, size: 20, color: palette.accent),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontSize: 14.5,
                          height: 1.4,
                          color: palette.ink,
                        ),
                        children: highlightedSpans(
                          item.body,
                          item.highlights,
                          const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    if (item.preview != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: palette.elevated,
                          borderRadius: BorderRadius.circular(
                            AppRadius.control,
                          ),
                          border: Border.all(color: palette.line),
                        ),
                        child: Text(
                          item.preview!,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.4,
                            color: palette.inkMuted,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Text(
                          Formatters.relative(item.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: palette.inkMuted,
                          ),
                        ),
                        if (item.actionLabel != null) ...[
                          const Spacer(),
                          Text(
                            item.actionLabel!,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: palette.accent,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (unread) ...[
                const SizedBox(width: AppSpacing.xs),
                Semantics(
                  label: 'Unread',
                  child: Container(
                    width: 9,
                    height: 9,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: palette.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Splits [body] into plain and [emphasis] spans: every part of the text that
/// matches one of [highlights] (a clinician's name, a date) is emphasised.
List<InlineSpan> highlightedSpans(
  String body,
  List<String> highlights,
  TextStyle emphasis,
) {
  final spans = <InlineSpan>[];
  var cursor = 0;
  while (cursor < body.length) {
    int? nextStart;
    String? nextMatch;
    for (final highlight in highlights) {
      if (highlight.isEmpty) continue;
      final at = body.indexOf(highlight, cursor);
      if (at == -1) continue;
      if (nextStart == null ||
          at < nextStart ||
          (at == nextStart && highlight.length > nextMatch!.length)) {
        nextStart = at;
        nextMatch = highlight;
      }
    }
    if (nextStart == null || nextMatch == null) {
      spans.add(TextSpan(text: body.substring(cursor)));
      break;
    }
    if (nextStart > cursor) {
      spans.add(TextSpan(text: body.substring(cursor, nextStart)));
    }
    spans.add(TextSpan(text: nextMatch, style: emphasis));
    cursor = nextStart + nextMatch.length;
  }
  return spans;
}
