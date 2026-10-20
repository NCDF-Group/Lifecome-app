import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/router/route_paths.dart';

/// Says plainly that Professional Care is a preview: nothing here reaches a
/// care provider yet.
class CarePreviewNotice extends StatelessWidget {
  const CarePreviewNotice({super.key});

  @override
  Widget build(BuildContext context) => const InfoBanner(
    tone: BannerTone.warning,
    message:
        'Professional Care is in preview. Requests stay in this app and are '
        'not sent to a care provider yet; names, times and costs are examples.',
  );
}

/// The scaffold every Care screen shares: header with a back link, then a
/// scrolling column.
class CarePage extends StatelessWidget {
  const CarePage({
    super.key,
    required this.children,
    this.backFallback = RoutePaths.care,
    this.onBack,
  });

  final List<Widget> children;
  final String backFallback;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 25),
          children: [
            AppHeaderBar(
              showBack: true,
              backFallback: backFallback,
              onBack: onBack,
            ),
            const SizedBox(height: 4),
            ...children,
          ],
        ),
      ),
    );
  }
}
