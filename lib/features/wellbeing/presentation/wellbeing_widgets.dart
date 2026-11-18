import 'package:flutter/material.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/layout/app_header_bar.dart';

/// The scaffold every Wellbeing screen shares.
class WellbeingPage extends StatelessWidget {
  const WellbeingPage({
    super.key,
    required this.children,
    this.backFallback = RoutePaths.wellbeing,
  });

  final List<Widget> children;
  final String backFallback;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 25),
          children: [
            AppHeaderBar(showBack: true, backFallback: backFallback),
            const SizedBox(height: 4),
            ...children,
          ],
        ),
      ),
    );
  }
}
