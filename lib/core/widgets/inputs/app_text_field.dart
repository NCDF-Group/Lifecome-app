import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';

/// The one text field style used everywhere in the app: a label above the
/// field (matching the website's form fields), an optional leading icon,
/// and consistent border and error handling from the app theme.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.errorText,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.inputFormatters,
  });

  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final String? errorText;
  final bool enabled;

  /// True for a field that opens a picker (e.g. date of birth) rather than
  /// accepting typed input directly.
  final bool readOnly;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          enabled: enabled,
          readOnly: readOnly,
          obscureText: obscureText,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          onTap: onTap,
          inputFormatters: inputFormatters,
          style: TextStyle(fontSize: 16, color: AppColors.ink),
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 20, color: AppColors.inkMuted)
                : null,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
