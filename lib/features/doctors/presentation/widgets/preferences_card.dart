import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_svg_icons.dart';

const bookingModes = ['Online or clinic', 'Online', 'In person'];
const bookingDates = ['Any date', 'Today', 'Tomorrow', 'This week'];
const bookingLanguages = ['Any language', 'English', 'Yoruba', 'Igbo', 'Hausa'];
const bookingLocations = ['Lagos', 'Abuja', 'London', 'Manchester'];

/// One "icon  label … value ⌄" row of a [PreferencesCard].
class PrefRow {
  const PrefRow({
    required this.glyph,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final AppSvgGlyph glyph;
  final String label;
  final String value;
  final VoidCallback onTap;
}

/// White bordered card of tappable preference rows split by hairlines. The
/// card has no outer padding of its own on the sides of [header]/[footer], so
/// callers can place an image above or a button below it.
class PreferencesCard extends StatelessWidget {
  const PreferencesCard({
    super.key,
    required this.rows,
    this.header,
    this.footer,
  });

  final List<PrefRow> rows;
  final Widget? header;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ?header,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFE7E9ED),
                    ),
                  InkWell(
                    onTap: rows[i].onTap,
                    child: SizedBox(
                      height: 62,
                      child: Row(
                        children: [
                          AppSvgIcon(
                            rows[i].glyph,
                            size: 24,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              rows[i].label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.4,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            rows[i].value,
                            style: const TextStyle(
                              fontSize: 16,
                              letterSpacing: -0.3,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const AppSvgIcon(
                            AppSvgGlyph.chevronDown,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          ?footer,
        ],
      ),
    );
  }
}

/// Bottom sheet listing [options]; resolves to the one tapped, or null.
Future<String?> showOptionSheet(
  BuildContext context, {
  required String title,
  required List<String> options,
  required String current,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: AppColors.white,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          for (final option in options)
            ListTile(
              title: Text(
                option,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: option == current
                      ? FontWeight.w700
                      : FontWeight.w400,
                  color: option == current
                      ? AppColors.actionBlue
                      : AppColors.textPrimary,
                ),
              ),
              trailing: option == current
                  ? const AppSvgIcon(
                      AppSvgGlyph.checkLine,
                      color: AppColors.actionBlue,
                    )
                  : null,
              onTap: () => Navigator.of(context).pop(option),
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
