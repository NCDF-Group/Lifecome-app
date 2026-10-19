import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';

/// The segmented progress bar and "STEP 2 OF 6" label at the top of a
/// multi-step journey (the screen pack's `.progress` and `.step-label`).
class StepProgress extends StatelessWidget {
  const StepProgress({super.key, required this.step, required this.total});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      label: 'Step $step of $total',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                for (var i = 0; i < total; i++) ...[
                  if (i > 0) const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: i < step ? palette.accent : palette.line,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 9),
            Text(
              'STEP $step OF $total',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 0.6,
                color: palette.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
