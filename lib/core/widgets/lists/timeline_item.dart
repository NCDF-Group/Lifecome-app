import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';
import '../media/lc_icons.dart';

/// A vertical progress timeline (the screen pack's `.timeline`): steps before
/// [active] are done (green dot), [active] is current (blue, ringed), the
/// rest are still to come.
class StepTimeline extends StatelessWidget {
  const StepTimeline({super.key, required this.items, this.active = 1});

  /// Each step's title and one line of explanation.
  final List<(String, String)> items;
  final int active;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 18, 0, 18),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 14,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        if (i < items.length - 1)
                          Positioned(
                            top: 0,
                            bottom: 0,
                            child: Container(width: 2, color: palette.line),
                          ),
                        Container(
                          margin: const EdgeInsets.only(top: 3),
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i < active
                                ? palette.positive
                                : i == active
                                ? palette.accent
                                : palette.line,
                            boxShadow: i == active
                                ? [
                                    BoxShadow(
                                      color: palette.tintBlueStrong,
                                      spreadRadius: 4,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: i == items.length - 1 ? 0 : 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            items[i].$1,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: palette.ink,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            items[i].$2,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: palette.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// A list of short points each with a green tick (the screen pack's
/// `.check-list`).
class CheckList extends StatelessWidget {
  const CheckList({super.key, required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          for (final item in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: LcIcon(
                      LcIcons.check,
                      size: 16,
                      color: palette.positive,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.55,
                        color: palette.inkMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
