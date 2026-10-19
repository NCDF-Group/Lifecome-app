import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons/secondary_button.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/detail_list.dart';
import '../../../core/widgets/layout/document_preview.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../domain/models/referral.dart';

/// One referral (screen pack 059): where it stands, who arranges the next
/// step, and the referral letter as written.
class ReferralDetailScreen extends StatelessWidget {
  const ReferralDetailScreen({super.key, required this.referral});

  final Referral referral;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 25),
          children: [
            const AppHeaderBar(
              showBack: true,
              backFallback: RoutePaths.healthRecords,
            ),
            const SizedBox(height: 4),
            ScreenTitle(
              title: 'Referral details',
              subtitle: referral.specialty,
            ),
            const SizedBox(height: 10),
            DetailList(
              rows: [
                ('Reference', referral.reference),
                ('Status', referral.status),
                ('Referred on', Formatters.longDate(referral.createdOn)),
                if (referral.nextStep != null)
                  ('Next step', referral.nextStep!),
              ],
            ),
            const SizedBox(height: 8),
            const InfoBanner(
              message:
                  'Referral appointments and any fees are arranged with the '
                  'receiving provider.',
            ),
            if (referral.letter != null)
              DocumentPreview(title: 'Referral letter', body: referral.letter!),
            const SizedBox(height: 8),
            SecondaryButton(
              label: 'Ask your care team',
              onPressed: () => context.go(RoutePaths.messages),
            ),
          ],
        ),
      ),
    );
  }
}
