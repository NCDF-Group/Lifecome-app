import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/detail_list.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/lists/row_card.dart';
import '../../../core/widgets/media/lc_icons.dart';

/// Payment methods (screen pack 027). The app does not keep cards: each
/// visit is paid through the secure payment provider when it is booked, or
/// by a linked plan or employer benefit. This says so, and points to those.
class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

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
              backFallback: RoutePaths.profile,
            ),
            const SizedBox(height: 4),
            const ScreenTitle(
              title: 'Payment methods',
              subtitle: 'How you pay for care.',
            ),
            const SizedBox(height: 10),
            const PanelCard(
              title: 'Pay when you book',
              body:
                  'You pay for each visit securely when you confirm the '
                  'booking. Card details are handled by our payment provider '
                  'and are not saved in the app.',
              tone: PanelTone.blue,
            ),
            RowCard(
              icon: LcIcons.shield,
              title: 'Membership & benefits',
              subtitle: 'Use a plan or employer benefit instead',
              tone: RowCardTone.mint,
              onTap: () => context.push(RoutePaths.myBenefits),
            ),
            const SizedBox(height: 8),
            const InfoBanner(
              message:
                  'Never share your full card number by message. LifeCome '
                  'will never ask for it.',
            ),
          ],
        ),
      ),
    );
  }
}
