import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';
import '../media/lc_icons.dart';

/// The colour family a [RecoveryView]'s round icon is drawn in.
enum RecoveryTone { blue, amber, green }

/// A recovery state (the screen pack's `.empty` and its 142-149 screens):
/// a large line icon, what happened in plain words, and the ways forward —
/// a main action, an alternative and a quiet last resort.
///
/// Every action can carry one of the [LcIcons] on its left; the main and
/// alternative actions always end in a chevron, as in the screen pack.
/// [details] sit between the message and the actions (an amount, a note, a
/// row of shortcuts).
class RecoveryView extends StatelessWidget {
  const RecoveryView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.tone = RecoveryTone.blue,
    this.details = const [],
    this.primaryLabel,
    this.primaryIcon,
    this.onPrimary,
    this.primaryLoading = false,
    this.secondaryLabel,
    this.secondaryIcon,
    this.onSecondary,
    this.ghostLabel,
    this.onGhost,
  });

  /// One of the [LcIcons].
  final String icon;
  final String title;
  final String message;
  final RecoveryTone tone;
  final List<Widget> details;
  final String? primaryLabel;
  final String? primaryIcon;
  final VoidCallback? onPrimary;
  final bool primaryLoading;
  final String? secondaryLabel;
  final String? secondaryIcon;
  final VoidCallback? onSecondary;
  final String? ghostLabel;
  final VoidCallback? onGhost;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final (circle, glyph) = switch (tone) {
      RecoveryTone.blue => (palette.tintBlue, palette.accent),
      RecoveryTone.amber => (palette.tintAmber, palette.amber),
      RecoveryTone.green => (palette.tintGreen, palette.positive),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(color: circle, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: LcIcon(icon, size: 52, color: glyph),
            ),
          ),
          const SizedBox(height: 22),
          Semantics(
            header: true,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                height: 1.15,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
                color: palette.ink,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: palette.inkMuted,
            ),
          ),
          for (final child in details) ...[const SizedBox(height: 16), child],
          if (primaryLabel != null) ...[
            const SizedBox(height: 24),
            _ActionButton(
              label: primaryLabel!,
              icon: primaryIcon,
              loading: primaryLoading,
              onPressed: onPrimary,
              filled: true,
            ),
          ],
          if (secondaryLabel != null) ...[
            const SizedBox(height: 12),
            _ActionButton(
              label: secondaryLabel!,
              icon: secondaryIcon,
              onPressed: onSecondary,
              filled: false,
            ),
          ],
          if (ghostLabel != null) ...[
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: onGhost,
                style: TextButton.styleFrom(
                  foregroundColor: palette.accent,
                  textStyle: const TextStyle(
                    fontFamily: appFontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
                child: Text(ghostLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A full-width action: the filled blue one, or the light-blue one. The label
/// sits in the middle (after the optional icon) and a chevron ends the row.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onPressed,
    required this.filled,
    this.icon,
    this.loading = false,
  });

  final String label;
  final String? icon;
  final VoidCallback? onPressed;
  final bool filled;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final foreground = filled ? AppColors.white : palette.accent;
    final enabled = onPressed != null && !loading;
    return SizedBox(
      height: 52,
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: filled ? AppColors.blue : palette.tintBlue,
          disabledBackgroundColor: (filled ? AppColors.blue : palette.tintBlue)
              .withValues(alpha: 0.5),
          foregroundColor: foreground,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          textStyle: const TextStyle(
            fontFamily: appFontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: loading
            ? SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: foreground,
                ),
              )
            : Row(
                children: [
                  if (icon != null)
                    LcIcon(icon!, size: 22, color: foreground)
                  else
                    const SizedBox(width: 22),
                  Expanded(child: Text(label, textAlign: TextAlign.center)),
                  LcIcon(LcIcons.chevron, size: 20, color: foreground),
                ],
              ),
      ),
    );
  }
}
