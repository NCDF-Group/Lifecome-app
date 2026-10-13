import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/services/session_store.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../booking/domain/models/appointment.dart';
import '../../services/domain/models/wellbeing_service.dart';

/// The Home tab — "How can we help today?", matching the redesigned
/// screenshots: a greeting, the primary booking CTA, Online GP / Clinic
/// care, the Everyday wellbeing section, quick links, and urgent help.
/// "Online GP"/"Clinic care"/"Book a GP appointment" go straight into the
/// direct-pay booking flow; the HMO/employer-covered path lives behind
/// "Employer access" instead of gating booking up front (see
/// `RoutePaths.payerSelectHmo`'s own doc comment).
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

  String get _firstName {
    final name = _session?.displayName;
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
      extra: (BookingAccessType.direct, null),
    );
  }

  @override
  Widget build(BuildContext context) {
    const countryName = 'England';

    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const AppHeaderBar(),
            const SizedBox(height: 20),
            Text(
              '$_greeting, $_firstName',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: context.palette.inkMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'How can we help today?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: context.palette.ink,
              ),
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'Book a GP appointment',
              icon: Icons.arrow_forward,
              onPressed: _openDirectBooking,
            ),
            const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _QuickCard(
                      icon: Icons.computer_outlined,
                      background: context.palette.tintGreen,
                      iconColor: context.palette.positive,
                      title: 'Online GP',
                      subtitle: 'Care while in $countryName',
                      onTap: _openDirectBooking,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickCard(
                      icon: Icons.apartment_outlined,
                      background: context.palette.tintBlue,
                      iconColor: context.palette.accent,
                      title: 'Clinic care',
                      subtitle: 'Find a clinic',
                      onTap: _openDirectBooking,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.palette.tintGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: context.palette.elevated,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.eco_outlined,
                          color: context.palette.positive,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Everyday wellbeing',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: context.palette.ink,
                              ),
                            ),
                            Text(
                              'Practical support for healthier living.',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: context.palette.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  for (final service in wellbeingServices) ...[
                    _WellbeingRow(
                      service: service,
                      onTap: () => context.push(
                        RoutePaths.wellbeingService,
                        extra: service,
                      ),
                    ),
                    if (service != wellbeingServices.last)
                      const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _QuickCard(
                      icon: Icons.calendar_month_outlined,
                      background: context.palette.tintGreen,
                      iconColor: context.palette.positive,
                      title: 'My bookings',
                      subtitle: 'Appointments and sessions',
                      onTap: () => context.go(RoutePaths.visits),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickCard(
                      icon: Icons.description_outlined,
                      background: context.palette.tintBlue,
                      iconColor: context.palette.accent,
                      title: 'Health records',
                      subtitle: 'Your clinical care',
                      onTap: () => context.go(RoutePaths.healthRecords),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _WideRow(
              icon: Icons.business_outlined,
              iconColor: context.palette.accent,
              title: 'Employer access',
              subtitle: 'Check what your package includes',
              onTap: () => context.push(RoutePaths.payerSelectHmo),
            ),
            const SizedBox(height: 10),
            _WideRow(
              icon: Icons.emergency_outlined,
              iconColor: context.palette.danger,
              title: 'Need urgent help?',
              titleColor: context.palette.danger,
              background: context.palette.tintRed,
              onTap: () =>
                  showComingSoonPopup(context, feature: 'Emergency guidance'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.icon,
    required this.background,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: iconColor, size: 22),
                  const Spacer(),
                  Icon(Icons.chevron_right, color: iconColor, size: 18),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: context.palette.ink,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: context.palette.inkMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WellbeingRow extends StatelessWidget {
  const _WellbeingRow({required this.service, required this.onTap});

  final WellbeingService service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.palette.elevated,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  service.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: context.palette.ink,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: context.palette.positive,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WideRow extends StatelessWidget {
  const _WideRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.titleColor,
    this.background,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final Color? background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background ?? context.palette.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: titleColor ?? context.palette.ink,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.palette.inkMuted,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: iconColor),
            ],
          ),
        ),
      ),
    );
  }
}
