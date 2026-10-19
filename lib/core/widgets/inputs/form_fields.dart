import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';

/// The bold label above a form control (the screen pack's `.field > span`).
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: context.palette.ink,
        ),
      ),
    );
  }
}

/// A labelled drop-down of fixed options (the screen pack's `select`).
class SelectField extends StatelessWidget {
  const SelectField({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final List<String> options;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldLabel(label),
          DropdownButtonFormField<String>(
            initialValue: value,
            isExpanded: true,
            items: [
              for (final option in options)
                DropdownMenuItem(value: option, child: Text(option)),
            ],
            onChanged: (next) {
              if (next != null) onChanged(next);
            },
            style: TextStyle(fontSize: 15, color: context.palette.ink),
          ),
        ],
      ),
    );
  }
}

/// A labelled multi-line text box (the screen pack's `textarea`).
class TextAreaField extends StatelessWidget {
  const TextAreaField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.errorText,
    this.onChanged,
    this.optional = false,
    this.maxLines = 4,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  /// Adds "(optional)" to the label.
  final bool optional;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldLabel(optional ? '$label (optional)' : label),
          TextField(
            controller: controller,
            minLines: 3,
            maxLines: maxLines,
            onChanged: onChanged,
            style: TextStyle(fontSize: 15, color: context.palette.ink),
            decoration: InputDecoration(
              hintText: hintText,
              errorText: errorText,
            ),
          ),
        ],
      ),
    );
  }
}
