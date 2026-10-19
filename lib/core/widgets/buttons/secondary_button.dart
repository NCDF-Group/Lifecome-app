import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';

/// The outlined blue button (the screen pack's `.btn.secondary`). Used for a
/// lower-emphasis action next to a [PrimaryButton].
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
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: context.palette.accent,
          backgroundColor: context.palette.elevated,
          side: BorderSide(color: context.palette.tintBlueLine),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          textStyle: const TextStyle(
            fontFamily: appFontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
