import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/services/session_store.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/layout/section_header.dart';
import '../../../core/widgets/lists/row_card.dart';
import '../../../core/widgets/media/lc_icons.dart';
import '../../booking/application/booking_controller.dart';
import '../../booking/domain/models/appointment.dart';
import '../../booking/domain/models/booking_selection.dart';
import '../../profile/application/profile_controller.dart';

/// The Home tab — the screen pack's "How can we help today?" (008): the
/// four services (GP, Care, Wellbeing, Insurance), the next step (the next
/// real visit, or booking one), shared shortcuts and urgent help.
///
/// GP goes straight into the direct-pay booking flow and Wellbeing to the
/// existing services page until their hubs are built; Care and Insurance
/// say they are coming soon.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  StoredSession? _session;

  @override
  void initState() {
    super.initState();
    ref.read(sessionStoreProvider).read().then((session) {
      if (mounted) setState(() => _session = session);
    });
  }

  /// The first name from the profile, or the one saved at sign-in while the
  /// profile is still loading (or if the account has none yet).
  String get _firstName {
    final profileName = ref.watch(meProvider).value?.profile?.firstName;
    final name = (profileName != null && profileName.isNotEmpty)
        ? profileName
        : _session?.displayName;
    if (name == null || name.isEmpty) return 'there';
    return name.split(' ').first;
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _openDirectBooking() {
    context.push(
      RoutePaths.bookingChooseService,
      extra: const BookingStart.direct(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final needsProfile = ref.watch(meProvider).value?.needsProfile ?? false;
    final next = ref.watch(upcomingAppointmentsProvider).value?.firstOrNull;

    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 25),
          children: [
            const AppHeaderBar(),
            const SizedBox(height: 18),
            ScreenTitle(
              title: 'How can we\nhelp today?',
              subtitle: '$_greeting, $_firstName. Your health, connected.',
            ),
            const SizedBox(height: 22),
            if (needsProfile) ...[
              InfoBanner(
                tone: BannerTone.warning,
                title: 'Finish setting up your profile',
                message: 'We need a few details before you can book care.',
                actionLabel: 'Complete profile',
                onAction: () => context.push(RoutePaths.completeProfile),
              ),
              const SizedBox(height: 12),
            ],
            _ServiceGrid(
              onGp: _openDirectBooking,
              onCare: () =>
                  showComingSoonPopup(context, feature: 'Professional Care'),
              onWellbeing: () => context.push(RoutePaths.services),
              onInsurance: () =>
                  showComingSoonPopup(context, feature: 'Insurance'),
            ),
            if (next != null) ...[
              const SectionHeader(title: 'Your next visit'),
              _NextVisitCard(appointment: next),
            ] else ...[
              const SectionHeader(title: 'Your next step'),
              RowCard(
                icon: LcIcons.video,
                title: 'Book a GP appointment',
                subtitle: 'Choose a time that works for you',
                onTap: _openDirectBooking,
              ),
            ],
            const SectionHeader(title: 'Your health, together'),
            RowCard(
              icon: LcIcons.calendar,
              title: 'Visits & appointments',
              subtitle: 'Bookings across your services',
              onTap: () => context.go(RoutePaths.visits),
            ),
            RowCard(
              icon: LcIcons.file,
              title: 'Health records',
              subtitle: 'Consultation notes, referrals & results',
              onTap: () => context.go(RoutePaths.healthRecords),
            ),
            RowCard(
              icon: LcIcons.shield,
              title: 'Membership & benefits',
              subtitle: 'Your plan and employer access',
              tone: RowCardTone.mint,
              onTap: () => context.push(RoutePaths.myBenefits),
            ),
            const SizedBox(height: 13),
            UrgentHelpLink(onTap: () => context.push(RoutePaths.emergency)),
          ],
        ),
      ),
    );
  }
}

/// GP, Care, Wellbeing and Insurance as a two-by-two grid of [ServiceCard]s,
/// each row as tall as its tallest card.
class _ServiceGrid extends StatelessWidget {
  const _ServiceGrid({
    required this.onGp,
    required this.onCare,
    required this.onWellbeing,
    required this.onInsurance,
  });

  final VoidCallback onGp;
  final VoidCallback onCare;
  final VoidCallback onWellbeing;
  final VoidCallback onInsurance;

  @override
  Widget build(BuildContext context) {
    Widget pair(Widget a, Widget b) => IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: a),
          const SizedBox(width: 10),
          Expanded(child: b),
        ],
      ),
    );

    return Column(
      children: [
        pair(
          ServiceCard(
            icon: LcIcons.gp,
            title: 'GP',
            subtitle: 'Online, in-clinic & menopause care',
            tone: RowCardTone.blue,
            onTap: onGp,
          ),
          ServiceCard(
            icon: LcIcons.care,
            title: 'Care',
            subtitle: 'Professional care, built around you',
            onTap: onCare,
          ),
        ),
        const SizedBox(height: 10),
        pair(
          ServiceCard(
            icon: LcIcons.wellbeing,
            title: 'Wellbeing',
            subtitle: 'Support, coaching & the shop',
            onTap: onWellbeing,
          ),
          ServiceCard(
            icon: LcIcons.shield,
            title: 'Insurance',
            subtitle: 'Explore and manage your cover',
            tone: RowCardTone.blue,
            onTap: onInsurance,
          ),
        ),
      ],
    );
  }
}

/// The next booked visit, in the [RowCard] style.
class _NextVisitCard extends StatelessWidget {
  const _NextVisitCard({required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final uk = Formatters.ukTime(appointment.startsAt);
    final day = Formatters.dayLabel(DateTime(uk.year, uk.month, uk.day));

    return RowCard(
      icon: LcIcons.calendar,
      title: '${appointment.serviceName} · $day, ${Formatters.time(uk)}',
      subtitle: 'with ${appointment.providerName}',
      onTap: () =>
          context.push(RoutePaths.manageAppointment, extra: appointment),
    );
  }
}
