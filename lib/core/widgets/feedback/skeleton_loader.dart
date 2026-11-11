import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';

/// Animated placeholders for content that is being fetched.
///
/// The default layout resembles the app's tappable list rows. Use
/// [SkeletonLoader.inlineChips] for compact chip collections such as
/// appointment times.
class SkeletonLoader extends StatefulWidget {
  const SkeletonLoader({super.key, this.itemCount = 3, this.padding = 8})
    : inlineChips = false;

  const SkeletonLoader.inlineChips({super.key, this.padding = 8})
    : itemCount = 0,
      inlineChips = true;

  final int itemCount;
  final double padding;
  final bool inlineChips;

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Semantics(
      label: 'Loading content',
      liveRegion: true,
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final blockColor = Color.lerp(
              palette.line.withValues(alpha: 0.32),
              palette.line.withValues(alpha: 0.72),
              _controller.value,
            )!;

            if (widget.inlineChips) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: widget.padding),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final width in const [48.0, 64.0, 54.0, 72.0])
                      _Block(
                        color: blockColor,
                        width: width,
                        height: 32,
                        radius: 10,
                      ),
                  ],
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.symmetric(vertical: widget.padding),
              child: Column(
                children: [
                  for (var index = 0; index < widget.itemCount; index++) ...[
                    if (index > 0) const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: palette.tintBlueFaint,
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(
                          color: palette.tintBlueLine.withValues(alpha: 0.45),
                        ),
                      ),
                      child: Row(
                        children: [
                          _Block(
                            color: blockColor,
                            width: 42,
                            height: 42,
                            radius: 21,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: index == 1 ? 0.48 : 0.62,
                                  child: _Block(color: blockColor, height: 13),
                                ),
                                const SizedBox(height: 8),
                                FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: index == 2 ? 0.55 : 0.88,
                                  child: _Block(color: blockColor, height: 10),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          _Block(
                            color: blockColor,
                            width: 8,
                            height: 12,
                            radius: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({
    required this.color,
    this.width,
    required this.height,
    this.radius = 6,
  });

  final Color color;
  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
