import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// A compact "step X of N" progress indicator — a row of small pill
/// segments, filled for the current step and every step before it, outlined
/// for what's still ahead. Sits where [AuthTopBar]'s "Log In" button used to
/// be, on the two-step create-account form.
class StepIndicator extends StatelessWidget {
  const StepIndicator({
    super.key,
    required this.step,
    required this.totalSteps,
  });

  /// 1-based - `step: 1` on the first screen, not `0`.
  final int step;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 1; index <= totalSteps; index++) ...[
          if (index > 1) const SizedBox(width: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22,
            height: 6,
            decoration: BoxDecoration(
              color: index <= step ? AppColors.blue : AppColors.line,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: index <= step ? AppColors.blue : AppColors.line,
                width: 1.5,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
