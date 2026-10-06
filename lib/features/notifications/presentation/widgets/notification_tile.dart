import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_svg_icons.dart';
import '../../domain/models/notification_item.dart';

/// One row of the notification list: a round icon, the title with its
/// timestamp and unread dot, the message, then an optional quoted snippet
/// or outlined action button.
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.item,
    required this.onAction,
  });

  final NotificationItem item;
  final VoidCallback onAction;

  static AppSvgGlyph _glyphFor(NotificationKind kind) => switch (kind) {
    NotificationKind.booking => AppSvgGlyph.calendarBold,
    NotificationKind.message => AppSvgGlyph.chatBold,
    NotificationKind.support => AppSvgGlyph.chatsBold,
    NotificationKind.record => AppSvgGlyph.documentBold,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onAction,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white,
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Center(
              child: AppSvgIcon(
                _glyphFor(item.kind),
                size: 22,
                color: AppColors.actionBlue,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      item.timeLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    if (item.unread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.green,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                _RichBody(text: item.body, boldParts: item.boldParts),
                if (item.preview != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Text(
                      item.preview!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
                if (item.actionLabel != null) ...[
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: onAction,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.actionBlue,
                      side: const BorderSide(color: AppColors.cardBorder),
                      shape: const StadiumBorder(),
                      minimumSize: const Size(0, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item.kind == NotificationKind.booking) ...[
                          const AppSvgIcon(AppSvgGlyph.calendarBold, size: 22),
                          const SizedBox(width: 10),
                        ],
                        Text(item.actionLabel!),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A message in secondary grey with the [boldParts] picked out in the
/// primary text colour and a heavier weight.
class _RichBody extends StatelessWidget {
  const _RichBody({required this.text, required this.boldParts});

  final String text;
  final List<String> boldParts;

  @override
  Widget build(BuildContext context) {
    const base = TextStyle(
      fontSize: 16,
      height: 1.4,
      color: AppColors.textSecondary,
    );
    const bold = TextStyle(
      fontSize: 16,
      height: 1.4,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    );

    final spans = <TextSpan>[];
    var rest = text;
    while (rest.isNotEmpty) {
      var nextIndex = -1;
      String? nextPart;
      for (final part in boldParts) {
        final i = rest.indexOf(part);
        if (i != -1 && (nextIndex == -1 || i < nextIndex)) {
          nextIndex = i;
          nextPart = part;
        }
      }
      if (nextPart == null) {
        spans.add(TextSpan(text: rest));
        break;
      }
      if (nextIndex > 0) {
        spans.add(TextSpan(text: rest.substring(0, nextIndex)));
      }
      spans.add(TextSpan(text: nextPart, style: bold));
      rest = rest.substring(nextIndex + nextPart.length);
    }

    return Text.rich(TextSpan(style: base, children: spans));
  }
}
