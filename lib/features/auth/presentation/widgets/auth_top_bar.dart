import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';

/// The header used across the sign-up flow (create account, verify email,
/// create password): a circular back button, plus an optional [trailing]
/// widget for whatever belongs in the opposite corner — the step indicator
/// on the two-step account form, or nothing at all on the screens after it.
class AuthTopBar extends StatelessWidget {
  const AuthTopBar({super.key, this.onBack, this.trailing});

  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _CircleBackButton(onPressed: onBack ?? () => context.pop()),
        trailing ?? const SizedBox.shrink(),
      ],
    );
  }
}

class _CircleBackButton extends StatelessWidget {
  const _CircleBackButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      shape: CircleBorder(side: BorderSide(color: AppColors.line, width: 1.5)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(Icons.arrow_back, color: AppColors.ink, size: 20),
        ),
      ),
    );
  }
}
