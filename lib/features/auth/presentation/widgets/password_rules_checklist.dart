import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// The checklist shown under a new-password field on both the sign-up and
/// forgot-password flows. The first two rules tick off as the password
/// being typed satisfies them; the last two are reminders the app can't
/// verify (e.g. "easy to remember"), shown checked from the start.
class PasswordRulesChecklist extends StatelessWidget {
  const PasswordRulesChecklist({super.key, required this.password});

  final String password;

  bool get _hasMinLength => password.length >= 8;
  bool get _hasMixedCase =>
      RegExp(r'[a-z]').hasMatch(password) && RegExp(r'[A-Z]').hasMatch(password);
  bool get _hasNumber => RegExp(r'\d').hasMatch(password);
  bool get _hasSymbol => RegExp(r'[^A-Za-z0-9]').hasMatch(password);

  bool get meetsAllRules =>
      _hasMinLength && _hasMixedCase && _hasNumber && _hasSymbol;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Rule(met: _hasMinLength, label: 'Use at least 8 characters'),
        const SizedBox(height: AppSpacing.xxs),
        _Rule(
          met: _hasMixedCase && _hasNumber && _hasSymbol,
          label: 'At least 1 uppercase, 1 lowercase, 1 number, & 1 symbol',
        ),
        const SizedBox(height: AppSpacing.xxs),
        const _Rule(met: true, label: 'Easy for you to remember'),
        const SizedBox(height: AppSpacing.xxs),
        const _Rule(met: true, label: 'Keep it private and secure'),
      ],
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule({required this.met, required this.label});

  final bool met;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = met ? AppColors.ink : AppColors.inkMuted;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          met ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 18,
          color: met ? AppColors.greenStrong : AppColors.inkMuted,
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: color, height: 1.3),
          ),
        ),
      ],
    );
  }
}
