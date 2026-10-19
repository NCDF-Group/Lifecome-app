import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/models/message_thread.dart';

/// One message in a conversation: the patient's on the right, the care team's
/// on the left. The time is UK time.
class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message});

  final ThreadMessage message;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final time = Formatters.time(Formatters.ukTime(message.sentAt));
    final maxWidth = MediaQuery.of(context).size.width * 0.72;

    if (message.fromPatient) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(time, style: TextStyle(fontSize: 11, color: palette.inkMuted)),
            const SizedBox(height: 2),
            Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: palette.tintGreen,
                borderRadius: BorderRadius.circular(15),
              ),
              child: SelectableText(
                message.body,
                style: TextStyle(
                  fontSize: 14,
                  color: palette.ink,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: palette.tintBlue,
            child: Icon(Icons.support_agent, size: 16, color: palette.accent),
          ),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Care team',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: palette.ink,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      time,
                      style: TextStyle(fontSize: 11, color: palette.inkMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: palette.tintBlue,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: SelectableText(
                    message.body,
                    style: TextStyle(
                      fontSize: 14,
                      color: palette.ink,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
