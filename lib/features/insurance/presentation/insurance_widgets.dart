import 'package:flutter/material.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/layout/app_header_bar.dart';

/// Says plainly what in Insurance is a preview.
class InsurancePreviewNotice extends StatelessWidget {
  const InsurancePreviewNotice({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) => InfoBanner(
    tone: BannerTone.warning,
    message:
        message ??
        'Insurance enquiries, claims and support are in preview: they stay in '
            'this app and no insurer or provider receives them.',
  );
}

/// The scaffold every Insurance screen shares.
class InsurancePage extends StatelessWidget {
  const InsurancePage({
    super.key,
    required this.children,
    this.backFallback = RoutePaths.insurance,
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

/// Small red/blue error line under a tick box.
class ConfirmError extends StatelessWidget {
  const ConfirmError({super.key, required this.show});

  final bool show;

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 30),
      child: Text(
        'Please confirm to continue.',
        style: TextStyle(fontSize: 12.5, color: context.palette.danger),
      ),
    );
  }
}
