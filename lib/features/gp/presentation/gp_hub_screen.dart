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
import '../../booking/domain/models/booking_selection.dart';
import '../../booking/domain/models/consultation_mode.dart';

/// "GP care, your way" — the GP services hub (screen pack 037). Online or
/// in-clinic GP start the booking at the eligibility step; Menopause Care
/// lives here too, with shortcuts to the person's existing GP care.
class GpHubScreen extends StatelessWidget {
  const GpHubScreen({super.key});

  void _book(BuildContext context, ConsultationMode mode) {
    context.push(
      RoutePaths.gpEligibility,
      extra: BookingStart.direct(mode: mode),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 25),
          children: [
            const AppHeaderBar(showBack: true),
            const SizedBox(height: 4),
            const ScreenTitle(
              eyebrow: 'GP services',
              title: 'GP care, your way',
              subtitle: 'Choose an appointment that fits your needs.',
            ),
            const SizedBox(height: 22),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ServiceCard(
                      icon: LcIcons.video,
                      title: 'Online GP',
                      subtitle: 'Speak to a GP by video',
                      tone: RowCardTone.blue,
                      onTap: () => _book(context, ConsultationMode.video),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ServiceCard(
                      icon: LcIcons.clinic,
                      title: 'In-clinic GP',
                      subtitle: 'See a GP in person',
                      onTap: () => _book(context, ConsultationMode.inPerson),
                    ),
                  ),
                ],
              ),
            ),
            const SectionHeader(title: 'Specialist support'),
            RowCard(
              icon: LcIcons.leaf,
              title: 'Menopause Care',
              subtitle: 'Assessment, consultation and ongoing review',
              tone: RowCardTone.mint,
              onTap: () => context.push(RoutePaths.menopause),
            ),
            const SectionHeader(title: 'Your GP care'),
            RowCard(
              icon: LcIcons.file,
              title: 'Health records',
              subtitle: 'Notes, prescriptions, referrals and results',
              onTap: () => context.go(RoutePaths.healthRecords),
            ),
            RowCard(
              icon: LcIcons.care,
              title: 'Your care plan',
              subtitle: 'Next steps after your consultation',
              onTap: () => context.push(RoutePaths.careplan),
            ),
            RowCard(
              icon: LcIcons.message,
              title: 'Message your GP team',
              subtitle: 'Support with your existing care',
              onTap: () => context.go(RoutePaths.messages),
            ),
            const SizedBox(height: 10),
            const InfoBanner(
              message: 'Consultation prices are shown before you confirm.',
            ),
          ],
        ),
      ),
    );
  }
}
