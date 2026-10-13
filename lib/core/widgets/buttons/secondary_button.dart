import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';

/// The outlined blue button, matching the website's secondary `ButtonLink`
/// variant. Used for a lower-emphasis action next to a [PrimaryButton].
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: context.palette.accent,
          side: BorderSide(color: context.palette.accent, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          textStyle: const TextStyle(
            fontFamily: appFontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
