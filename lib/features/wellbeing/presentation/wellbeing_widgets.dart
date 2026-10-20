import 'package:flutter/material.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/layout/app_header_bar.dart';

/// Says plainly that wellbeing sessions are a preview.
class WellbeingPreviewNotice extends StatelessWidget {
  const WellbeingPreviewNotice({super.key});

  @override
  Widget build(BuildContext context) => const InfoBanner(
    tone: BannerTone.warning,
    message:
        'Wellbeing sessions are in preview. Bookings stay in this app, no '
        'payment is taken, and the practitioner, times and fees are examples.',
  );
}

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
