import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/detail_list.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/lists/row_card.dart';
import '../../../core/widgets/media/lc_icons.dart';

/// "Privacy & permissions" (screen pack 028) — who can access the patient's records and why.
/// No sharing backend exists yet (nothing has ever been granted access),
/// so every row here just opens a coming-soon popup for now; the one true
/// fact this screen states ("No sharing permissions active") is accurate
/// by construction, not sample data.
class PrivacySharingScreen extends StatelessWidget {
  const PrivacySharingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void soon(String feature) => showComingSoonPopup(context, feature: feature);

    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 25),
          children: [
            const AppHeaderBar(
              showBack: true,
              backFallback: RoutePaths.profile,
            ),
            const SizedBox(height: 4),
            const ScreenTitle(
              title: 'Privacy & permissions',
              subtitle: 'You control how your information is used.',
            ),
            const SizedBox(height: 10),
            const PanelCard(
              title: 'No sharing permissions active',
              body: 'Nobody else can see your records.',
              tone: PanelTone.mint,
            ),
            RowCard(
              icon: LcIcons.people,
              title: 'Request supported sharing',
              subtitle:
                  'Ask a trusted person, carer or organisation to access '
                  'your records',
              onTap: () => soon('Supported sharing'),
            ),
            RowCard(
              icon: LcIcons.file,
              title: 'Review permissions',
              subtitle: 'See who can access your records and what they can see',
              tone: RowCardTone.mint,
              onTap: () => soon('Review permissions'),
            ),
            RowCard(
              icon: LcIcons.close,
              title: 'Revoke access',
              subtitle: "Remove a person or organisation's access",
              onTap: () => soon('Revoke access'),
            ),
            RowCard(
              icon: LcIcons.clock,
              title: 'Access history',
              subtitle: 'See when your records have been accessed',
              tone: RowCardTone.mint,
              onTap: () => soon('Access history'),
            ),
            const SizedBox(height: 8),
            const InfoBanner(
              title: 'Paying for care does not give access to your records.',
              message:
                  'Sharing requires specific permission and can be reviewed.',
            ),
            const SizedBox(height: 4),
            RowCard(
              icon: LcIcons.lock,
              title: 'Read our privacy notice',
              subtitle: 'How we use and protect your information',
              tone: RowCardTone.white,
              onTap: () => context.push(RoutePaths.privacyPolicy),
            ),
          ],
        ),
      ),
    );
  }
}
