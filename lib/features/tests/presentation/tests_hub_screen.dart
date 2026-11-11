import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/layout/section_header.dart';
import '../../../core/widgets/lists/row_card.dart';
import '../../../core/widgets/media/lc_icons.dart';
import 'test_journey_screens.dart';

/// Tests & Health Checks service catalogue.
class TestsHubScreen extends StatelessWidget {
  const TestsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 25),
          children: [
            const AppHeaderBar(showBack: true, backFallback: RoutePaths.home),
            const SizedBox(height: 4),
            const ScreenTitle(
              eyebrow: 'Tests & Health Checks',
              title: 'Know more about your health',
              subtitle:
                  'Explore checks and tests, then review what is right for you.',
            ),
            const SizedBox(height: 10),
            const InfoBanner(
              message:
                  'Services and prices shown here are examples. A clinician '
                  'must confirm suitability before any test is arranged.',
            ),
            const SectionHeader(title: 'Explore services'),
            for (final (index, service) in testServices.indexed)
              RowCard(
                icon: service.icon,
                title: service.title,
                subtitle: service.summary,
                tone: index.isEven ? RowCardTone.blue : RowCardTone.mint,
                onTap: () => context.push(
                  RoutePaths.testService.replaceFirst(
                    ':serviceId',
                    service.id,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            RowCard(
              icon: LcIcons.file,
              title: 'My tests & results',
              subtitle: 'Track requests and find results shared with you',
              tone: RowCardTone.white,
              onTap: () => context.push(RoutePaths.testResults),
            ),
          ],
        ),
      ),
    );
  }
}
