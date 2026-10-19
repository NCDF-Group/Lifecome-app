import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';

/// The big title at the top of a screen (the screen pack's `.page-title`),
/// with an optional green [eyebrow] above it and a one-line explanation
/// below.
class ScreenTitle extends StatelessWidget {
  const ScreenTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.eyebrow,
  });

  final String title;
  final String? subtitle;

  /// A short uppercase label above the title, e.g. "PROFESSIONAL CARE".
  final String? eyebrow;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[
          Text(
            eyebrow!.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3,
              color: context.palette.positive,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Semantics(
          header: true,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w700,
              height: 1.16,
              letterSpacing: -0.9,
              color: context.palette.ink,
            ),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 14,
              color: context.palette.inkMuted,
              height: 1.55,
            ),
          ),
        ],
      ],
    );
  }
}
