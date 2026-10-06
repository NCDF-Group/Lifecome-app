import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_svg_icons.dart';

/// Building blocks shared by the revamped Home, Book flow and Notifications
/// screens: soft bordered cards, pill buttons, info notes and page headings.

/// The soft rounded surface used across the screens: very light blue fill
/// and a hairline grey border.
class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.radius = 16,
    this.fill = AppColors.cardFill,
    this.borderColor = AppColors.cardBorder,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color fill;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(radius);
    return Material(
      color: fill,
      shape: RoundedRectangleBorder(
        borderRadius: shape,
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: shape,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Full-width pill button with a trailing chevron: filled blue by default,
/// or a blue outline with [outlined].
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.outlined = false,
    this.height = 50,
    this.fontSize = 18,
    this.showChevron = true,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool outlined;
  final double height;
  final double fontSize;
  final bool showChevron;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.3,
    );
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        if (showChevron) ...[
          const SizedBox(width: 10),
          AppSvgIcon(AppSvgGlyph.chevronLine, size: fontSize + 2),
        ],
      ],
    );
    final button = outlined
        ? OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.actionBlue,
              side: const BorderSide(color: AppColors.actionBlue),
              shape: const StadiumBorder(),
              textStyle: textStyle,
              padding: const EdgeInsets.symmetric(horizontal: 18),
            ),
            child: child,
          )
        : FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.actionBlue,
              foregroundColor: AppColors.white,
              shape: const StadiumBorder(),
              textStyle: textStyle,
              padding: const EdgeInsets.symmetric(horizontal: 18),
            ),
            child: child,
          );
    return SizedBox(
      width: expand ? double.infinity : null,
      height: height,
      child: button,
    );
  }
}

/// A blue-"i" note on a soft card, used for small reassurances.
class InfoNote extends StatelessWidget {
  const InfoNote(this.text, {super.key, this.centerIcon = false});

  final String text;

  /// Vertically centre the icon against the text (single-line notes).
  final bool centerIcon;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      radius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        crossAxisAlignment: centerIcon
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          const AppSvgIcon(
            AppSvgGlyph.infoBold,
            size: 22,
            color: AppColors.actionBlue,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                letterSpacing: -0.2,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bold page title with a grey subtitle beneath.
class PageHeading extends StatelessWidget {
  const PageHeading(this.title, {super.key, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
            color: AppColors.textPrimary,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: 14,
              letterSpacing: -0.2,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

/// The plain back arrow that sits above a page heading.
class DesignBackButton extends StatelessWidget {
  const DesignBackButton({super.key, this.onPressed});

  /// Overrides the default "pop, or go Home" behaviour.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        tooltip: 'Back',
        padding: EdgeInsets.zero,
        onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        icon: const AppSvgIcon(
          AppSvgGlyph.backLine,
          size: 26,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// A round tinted badge holding an icon (the calendar / pin / clock circle
/// at the top of a card).
class IconCircle extends StatelessWidget {
  const IconCircle({
    super.key,
    required this.glyph,
    this.color = AppColors.actionBlue,
    this.fill = const Color(0xFFD6E6F5),
    this.size = 50,
    this.iconSize = 24,
  });

  final AppSvgGlyph glyph;
  final Color color;
  final Color fill;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: fill),
      child: Center(
        child: AppSvgIcon(glyph, size: iconSize, color: color),
      ),
    );
  }
}

/// One entry of a [SlidingSegments] control.
class SegmentItem {
  const SegmentItem(this.label, {this.glyph});

  final String label;
  final AppSvgGlyph? glyph;
}

/// Segmented control: a blue block slides under the selected segment.
class SlidingSegments extends StatelessWidget {
  const SlidingSegments({
    super.key,
    required this.items,
    required this.selected,
    required this.onChanged,
    this.height = 56,
    this.fontSize = 19,
  });

  final List<SegmentItem> items;
  final int selected;
  final ValueChanged<int> onChanged;
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final n = items.length;
    return Container(
      height: height,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Stack(
        children: [
          // Positioned.fill: a Stack gives non-positioned children loose
          // constraints, so without it the labels sat at the top edge instead
          // of centred in the control.
          Positioned.fill(
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              alignment: Alignment(n == 1 ? 0 : -1 + 2 * selected / (n - 1), 0),
              child: FractionallySizedBox(
                widthFactor: 1 / n,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.actionBlue,
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Row(
              children: [
                for (var i = 0; i < n; i++)
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onChanged(i),
                      child: _SegmentLabel(
                        item: items[i],
                        selected: i == selected,
                        fontSize: fontSize,
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

class _SegmentLabel extends StatelessWidget {
  const _SegmentLabel({
    required this.item,
    required this.selected,
    required this.fontSize,
  });

  final SegmentItem item;
  final bool selected;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.white : AppColors.actionBlue;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (item.glyph != null) ...[
          AppSvgIcon(item.glyph!, size: 24, color: color),
          const SizedBox(width: 12),
        ],
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
            color: color,
          ),
          child: Text(item.label),
        ),
      ],
    );
  }
}

/// One line of a [DetailRows] card: icon, grey label, and a bold value with
/// an optional second line (grey, or a blue tappable link).
class DetailRow {
  const DetailRow({
    required this.glyph,
    required this.label,
    required this.value,
    this.sub,
    this.onSubTap,
  });

  final AppSvgGlyph glyph;
  final String label;
  final String value;
  final String? sub;

  /// When set, [sub] renders as a blue link with a chevron.
  final VoidCallback? onSubTap;
}

/// White bordered card of [DetailRow]s split by hairlines.
class DetailRows extends StatelessWidget {
  const DetailRows({super.key, required this.rows, this.title, this.header});

  final List<DetailRow> rows;
  final String? title;

  /// Optional block (e.g. a summary line) shown under [title], before [rows].
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title!,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.4,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          if (header != null) ...[
            const Divider(height: 1, thickness: 1, color: Color(0xFFE7E9ED)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: header,
            ),
          ],
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0 || title != null || header != null)
              const Divider(height: 1, thickness: 1, color: Color(0xFFE7E9ED)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppSvgIcon(
                    rows[i].glyph,
                    size: 24,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 14),
                  Text(
                    rows[i].label,
                    style: const TextStyle(
                      fontSize: 16,
                      letterSpacing: -0.3,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          rows[i].value,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.4,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (rows[i].sub != null) ...[
                          const SizedBox(height: 2),
                          rows[i].onSubTap == null
                              ? Text(
                                  rows[i].sub!,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    letterSpacing: -0.3,
                                    color: AppColors.textSecondary,
                                  ),
                                )
                              : InkWell(
                                  onTap: rows[i].onSubTap,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        rows[i].sub!,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          letterSpacing: -0.3,
                                          color: AppColors.actionBlue,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const AppSvgIcon(
                                        AppSvgGlyph.chevronLine,
                                        size: 16,
                                        color: AppColors.actionBlue,
                                      ),
                                    ],
                                  ),
                                ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A white bordered tappable row: blue icon, title, dark chevron. Pass
/// [soft] for the pale-blue variant.
class ActionRow extends StatelessWidget {
  const ActionRow({
    super.key,
    required this.glyph,
    required this.title,
    required this.onTap,
    this.soft = false,
    this.color = AppColors.actionBlue,
    this.titleColor = AppColors.textPrimary,
    this.trailingText,
  });

  final AppSvgGlyph glyph;
  final String title;
  final VoidCallback onTap;
  final bool soft;
  final Color color;
  final Color titleColor;

  /// Grey value shown before the chevron (e.g. the current country).
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      radius: 12,
      fill: soft ? AppColors.cardFill : AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          SizedBox(width: 30, child: AppSvgIcon(glyph, size: 26, color: color)),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.4,
                color: titleColor,
              ),
            ),
          ),
          if (trailingText != null) ...[
            Text(
              trailingText!,
              style: const TextStyle(
                fontSize: 16,
                letterSpacing: -0.3,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 8),
          ],
          AppSvgIcon(
            AppSvgGlyph.chevronLine,
            size: 22,
            color: titleColor == AppColors.textPrimary
                ? AppColors.textPrimary
                : titleColor,
          ),
        ],
      ),
    );
  }
}

/// A plain (no card) row: small blue icon, text, chevron — e.g. "Emergency
/// and urgent help" or "Cancellation terms".
class LinkRow extends StatelessWidget {
  const LinkRow({
    super.key,
    required this.glyph,
    required this.title,
    required this.onTap,
    this.color = AppColors.actionBlue,
    this.textColor = AppColors.textPrimary,
  });

  final AppSvgGlyph glyph;
  final String title;
  final VoidCallback onTap;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            AppSvgIcon(glyph, size: 24, color: color),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.4,
                  color: textColor,
                ),
              ),
            ),
            AppSvgIcon(
              AppSvgGlyph.chevronLine,
              size: 22,
              color: textColor == AppColors.textPrimary
                  ? AppColors.textPrimary
                  : textColor,
            ),
          ],
        ),
      ),
    );
  }
}
