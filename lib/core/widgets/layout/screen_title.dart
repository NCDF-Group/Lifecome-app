import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';

/// The big title (and optional one-line explanation) at the top of a screen.
class ScreenTitle extends StatelessWidget {
  const ScreenTitle({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: context.palette.ink,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 14,
              color: context.palette.inkMuted,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}
