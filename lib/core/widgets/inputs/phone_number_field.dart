import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_palette.dart';
import '../../theme/app_radius.dart';

const _ukDialCode = '+44';

/// A phone number field with a static UK (+44) prefix ahead of the local
/// number, matching the app's single bordered field look. LifeCome Live
/// serves the UK only, so there's no country selector here.
class PhoneNumberField extends StatefulWidget {
  const PhoneNumberField({
    super.key,
    required this.label,
    required this.onChanged,
    this.errorText,
  });

  final String label;

  /// Called with the full number (dial code + local digits, e.g.
  /// `+447700900123`) whenever the number changes.
  final ValueChanged<String> onChanged;
  final String? errorText;

  @override
  State<PhoneNumberField> createState() => _PhoneNumberFieldState();
}

class _PhoneNumberFieldState extends State<PhoneNumberField> {
  final _numberController = TextEditingController();

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  void _emit() {
    final digits = _numberController.text.trim();
    widget.onChanged(digits.isEmpty ? '' : '$_ukDialCode$digits');
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.errorText != null
        ? context.palette.danger
        : context.palette.line;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: context.palette.ink,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.control),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🇬🇧', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 6),
                    Text(
                      _ukDialCode,
                      style: TextStyle(
                        fontSize: 16,
                        color: context.palette.ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 28, color: context.palette.line),
              Expanded(
                child: TextField(
                  controller: _numberController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => _emit(),
                  style: TextStyle(fontSize: 16, color: context.palette.ink),
                  decoration: const InputDecoration(
                    hintText: 'Enter mobile number',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.errorText!,
            style: TextStyle(fontSize: 12, color: context.palette.danger),
          ),
        ],
      ],
    );
  }
}
