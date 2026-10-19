import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';
import '../../theme/app_radius.dart';
import '../media/lc_icons.dart';

/// The background a [RowCard] sits on.
enum RowCardTone { blue, mint, white }

/// A tappable row with a round icon, a title, a line of detail and a
/// chevron — the screen pack's `.row-card`, used for most navigation lists.
class RowCard extends StatelessWidget {
  const RowCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.tone = RowCardTone.blue,
    this.trailing,
  });

  /// One of the [LcIcons].
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final RowCardTone tone;

  /// Shown under the subtitle, e.g. a status badge.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final (background, border, iconDisc, iconColor) = switch (tone) {
      RowCardTone.blue => (
        palette.tintBlue,
        Colors.transparent,
        palette.tintBlueStrong,
        palette.accent,
      ),
      RowCardTone.mint => (
        palette.tintGreen,
        Colors.transparent,
        palette.tintGreenStrong,
        palette.positive,
      ),
      RowCardTone.white => (
        palette.elevated,
        palette.line,
        palette.tintBlueStrong,
        palette.accent,
      ),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(17),
          side: BorderSide(color: border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconDisc,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: LcIcon(icon, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                          color: palette.ink,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: palette.inkMuted,
                        ),
                      ),
                      if (trailing != null) ...[
                        const SizedBox(height: 6),
                        trailing!,
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                LcIcon(LcIcons.chevron, size: 16, color: palette.accent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The large tile for one of the four services on Home — the screen pack's
/// `.service-card`.
class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.tone = RowCardTone.mint,
  });

  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  /// [RowCardTone.blue] or [RowCardTone.mint].
  final RowCardTone tone;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final blue = tone == RowCardTone.blue;

    return Semantics(
      button: true,
      label: '$title. $subtitle',
      excludeSemantics: true,
      child: Material(
        color: blue ? palette.tintBlue : palette.tintGreen,
        borderRadius: BorderRadius.circular(19),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 160),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 17, 12, 17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: blue
                              ? palette.tintBlueStrong
                              : palette.tintGreenStrong,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: LcIcon(
                          icon,
                          color: blue ? palette.accent : palette.positive,
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: LcIcon(
                          LcIcons.chevron,
                          size: 16,
                          color: palette.accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      color: palette.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.45,
                      color: palette.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The red "Need urgent help?" link at the foot of Home and the help screens
/// (the screen pack's `.urgent`).
class UrgentHelpLink extends StatelessWidget {
  const UrgentHelpLink({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: palette.tintRed,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.button),
        side: BorderSide(color: palette.tintRedLine),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              LcIcon(LcIcons.info, size: 18, color: palette.danger),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Need urgent help?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: palette.danger,
                  ),
                ),
              ),
              LcIcon(LcIcons.chevron, size: 16, color: palette.danger),
            ],
          ),
        ),
      ),
    );
  }
}
