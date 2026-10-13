import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';

/// A filled light-blue pill button — a lower-emphasis action next to a
/// [PrimaryButton] that still reads as a real button, not a text link (e.g.
/// "Back to sign in", "Change number").
class TintedButton extends StatelessWidget {
  const TintedButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: context.palette.tintBlue,
          foregroundColor: context.palette.accent,
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
