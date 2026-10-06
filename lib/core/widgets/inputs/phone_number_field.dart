import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';

class PhoneCountry {
  const PhoneCountry({
    required this.flag,
    required this.dialCode,
    required this.name,
  });

  final String flag;
  final String dialCode;
  final String name;
}

const phoneCountries = [
  PhoneCountry(flag: '🇳🇬', dialCode: '+234', name: 'Nigeria'),
  PhoneCountry(flag: '🇬🇧', dialCode: '+44', name: 'United Kingdom'),
];

/// A phone number field with a country selector (flag + dial code) ahead of
/// the local number, matching the app's single bordered field look. Only
/// Nigeria and the UK are offered for now — see `phoneCountries`.
class PhoneNumberField extends StatefulWidget {
  const PhoneNumberField({
    super.key,
    required this.label,
    required this.onChanged,
    this.errorText,
  });

  final String label;

  /// Called with the full number (dial code + local digits, e.g.
  /// `+2348012345678`) whenever either part changes.
  final ValueChanged<String> onChanged;
  final String? errorText;

  @override
  State<PhoneNumberField> createState() => _PhoneNumberFieldState();
}

class _PhoneNumberFieldState extends State<PhoneNumberField> {
  final _numberController = TextEditingController();
  PhoneCountry _country = phoneCountries.first;

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  void _emit() {
    final digits = _numberController.text.trim();
    widget.onChanged(digits.isEmpty ? '' : '${_country.dialCode}$digits');
  }

  Future<void> _pickCountry() async {
    final selected = await showModalBottomSheet<PhoneCountry>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final country in phoneCountries)
              ListTile(
                leading: Text(
                  country.flag,
                  style: const TextStyle(fontSize: 22),
                ),
                title: Text(country.name),
                trailing: Text(
                  country.dialCode,
                  style: TextStyle(color: AppColors.inkMuted),
                ),
                onTap: () => Navigator.of(context).pop(country),
              ),
          ],
        ),
      ),
    );
    if (selected != null) {
      setState(() => _country = selected);
      _emit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.errorText != null
        ? AppColors.error
        : AppColors.line;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
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
              InkWell(
                borderRadius: BorderRadius.circular(AppRadius.control),
                onTap: _pickCountry,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_country.flag, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 6),
                      Text(
                        _country.dialCode,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 18,
                        color: AppColors.inkMuted,
                      ),
                    ],
                  ),
                ),
              ),
              Container(width: 1, height: 28, color: AppColors.line),
              Expanded(
                child: TextField(
                  controller: _numberController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => _emit(),
                  style: TextStyle(fontSize: 16, color: AppColors.ink),
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
            style: const TextStyle(fontSize: 12, color: AppColors.error),
          ),
        ],
      ],
    );
  }
}
