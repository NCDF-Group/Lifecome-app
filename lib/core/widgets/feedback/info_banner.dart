import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

enum BannerTone { info, success, warning, danger }

/// A rounded, tinted note with an icon: a heads-up, a reassurance, a warning.
class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.message,
    this.title,
    this.tone = BannerTone.info,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? title;
  final BannerTone tone;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final (background, color, defaultIcon) = switch (tone) {
      BannerTone.info => (palette.tintBlue, palette.accent, Icons.info_outline),
      BannerTone.success => (
        palette.tintGreen,
        palette.positive,
        Icons.check_circle_outline,
      ),
      BannerTone.warning => (
        palette.tintAmber,
        palette.amber,
        Icons.warning_amber_rounded,
      ),
      BannerTone.danger => (
        palette.tintRed,
        palette.danger,
        Icons.error_outline,
      ),
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? defaultIcon, size: 18, color: color),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: palette.ink,
                    ),
                  ),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: title == null ? palette.ink : palette.inkMuted,
                    height: 1.4,
                    fontWeight: title == null
                        ? FontWeight.w500
                        : FontWeight.w400,
                  ),
                ),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: onAction,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        actionLabel!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
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
