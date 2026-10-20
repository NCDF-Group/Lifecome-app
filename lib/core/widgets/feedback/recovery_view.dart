import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';
import '../buttons/ghost_button.dart';
import '../buttons/primary_button.dart';
import '../buttons/secondary_button.dart';
import '../media/lc_icons.dart';

/// A recovery state (the screen pack's `.empty` and its 142-149 screens):
/// a large line icon, what happened in plain words, and the ways forward —
/// a main action, an alternative and a quiet last resort.
class RecoveryView extends StatelessWidget {
  const RecoveryView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.primaryLabel,
    this.onPrimary,
    this.primaryLoading = false,
    this.secondaryLabel,
    this.onSecondary,
    this.ghostLabel,
    this.onGhost,
  });

  /// One of the [LcIcons].
  final String icon;
  final String title;
  final String message;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final bool primaryLoading;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final String? ghostLabel;
  final VoidCallback? onGhost;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: LcIcon(
              icon,
              size: 48,
              color: palette.accent.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          Semantics(
            header: true,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.6,
                color: palette.ink,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: palette.inkMuted,
            ),
          ),
          if (primaryLabel != null) ...[
            const SizedBox(height: 18),
            PrimaryButton(
              label: primaryLabel!,
              loading: primaryLoading,
              onPressed: onPrimary,
            ),
          ],
          if (secondaryLabel != null) ...[
            const SizedBox(height: 10),
            SecondaryButton(label: secondaryLabel!, onPressed: onSecondary),
          ],
          if (ghostLabel != null) ...[
            const SizedBox(height: 4),
            GhostButton(label: ghostLabel!, onPressed: onGhost),
          ],
        ],
      ),
    );
  }
}
