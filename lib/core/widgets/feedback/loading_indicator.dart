import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';

/// A centred spinner for a screen or section that is still loading.
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.padding = 40});

  final double padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.6,
            color: context.palette.accent,
            semanticsLabel: 'Loading',
          ),
        ),
      ),
    );
  }
}
