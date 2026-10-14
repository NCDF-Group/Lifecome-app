import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/feedback/empty_state.dart';
import '../../../core/widgets/feedback/error_state.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/feedback/loading_indicator.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../application/booking_controller.dart';
import '../domain/models/booking_selection.dart';
import '../domain/models/clinical_service.dart';
import '../domain/models/consultation_mode.dart';

enum _AppointmentFormat { online, clinic }

IconData _iconFor(ClinicalService service) {
  final text = '${service.code} ${service.name}'.toLowerCase();
  if (text.contains('follow')) return Icons.calendar_month_outlined;
  if (text.contains('result')) return Icons.description_outlined;
  if (text.contains('referral')) return Icons.person_outline;
  if (text.contains('consult')) return Icons.workspace_premium_outlined;
  return Icons.medical_services_outlined;
}

/// Blueprint views 09 (Check Service Eligibility, HMO path) and 10 (Choose a
/// Service, direct-pay path) — the same underlying choice, so one screen
/// serves both. The services and their prices come from the backend.
class ChooseServiceScreen extends ConsumerStatefulWidget {
  const ChooseServiceScreen({super.key, required this.start});

  final BookingStart start;

  @override
  ConsumerState<ChooseServiceScreen> createState() =>
      _ChooseServiceScreenState();
}

class _ChooseServiceScreenState extends ConsumerState<ChooseServiceScreen> {
  String? _selectedId;
  _AppointmentFormat _format = _AppointmentFormat.online;

  bool get _isHmo => widget.start.accessType == BookingAccessType.hmo;

  /// Started from the clinic finder: the clinician and the visit type are
  /// already decided.
  bool get _clinicianChosen => widget.start.doctor != null;

  ClinicalService? _selected(List<ClinicalService> services) {
    if (services.isEmpty) return null;
    for (final service in services) {
      if (service.id == _selectedId) return service;
    }
    return services.first;
  }

  void _continue(ClinicalService service) {
    final doctor = widget.start.doctor;
    final inPerson = _clinicianChosen || _format == _AppointmentFormat.clinic;
    context.push(
      RoutePaths.bookingLocation,
      extra: BookingSelection(
        accessType: widget.start.accessType,
        hmoName: widget.start.hmoName,
        service: service,
        doctor: doctor,
        mode: inPerson ? ConsultationMode.inPerson : ConsultationMode.video,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final services = ref.watch(clinicalServicesProvider);
    final selected = services.hasValue
        ? _selected(services.requireValue)
        : null;

    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  const AppHeaderBar(showBack: true),
                  const SizedBox(height: 20),
                  const ScreenTitle(
                    title: 'What care do you need?',
                    subtitle:
                        'Choose a service to get started. Services depend on '
                        'your location and availability.',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (_isHmo && widget.start.hmoName != null) ...[
                    InfoBanner(
                      tone: BannerTone.success,
                      icon: Icons.health_and_safety_outlined,
                      message: 'Access: ${widget.start.hmoName}',
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  if (_clinicianChosen) ...[
                    InfoBanner(
                      icon: Icons.apartment_outlined,
                      message:
                          'In-person appointment with ${widget.start.doctor!.name}.',
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  services.when(
                    loading: () => const LoadingIndicator(),
                    error: (error, _) => ErrorState(
                      error: error,
                      onRetry: () => ref.invalidate(clinicalServicesProvider),
                    ),
                    data: (list) => list.isEmpty
                        ? const EmptyState(
                            icon: Icons.medical_services_outlined,
                            title: 'No services are available right now',
                            message: 'Please check back soon.',
                          )
                        : Column(
                            children: [
                              for (var i = 0; i < list.length; i++) ...[
                                _ServiceTile(
                                  service: list[i],
                                  green: i.isEven,
                                  selected: list[i].id == selected?.id,
                                  onTap: () =>
                                      setState(() => _selectedId = list[i].id),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                              ],
                            ],
                          ),
                  ),
                  if (!_clinicianChosen && services.hasValue) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'How would you like to have your appointment?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: context.palette.ink,
                      ),
                    ),
                    Text(
                      'Choose one option.',
                      style: TextStyle(
                        fontSize: 13,
                        color: context.palette.inkMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _FormatCard(
                              background: context.palette.tintGreen,
                              iconColor: context.palette.positive,
                              icon: Icons.desktop_windows_outlined,
                              title: 'Online GP',
                              subtitle: 'Video or telephone\nappointment.',
                              selected: _format == _AppointmentFormat.online,
                              onTap: () => setState(
                                () => _format = _AppointmentFormat.online,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: _FormatCard(
                              background: context.palette.tintBlue,
                              iconColor: context.palette.accent,
                              icon: Icons.apartment_outlined,
                              title: 'Smart GP clinic',
                              subtitle: 'In person\nat a local clinic.',
                              selected: _format == _AppointmentFormat.clinic,
                              onTap: () => setState(
                                () => _format = _AppointmentFormat.clinic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: PrimaryButton(
                label: 'Continue',
                icon: Icons.arrow_forward,
                onPressed: selected == null ? null : () => _continue(selected),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.service,
    required this.green,
    required this.selected,
    required this.onTap,
  });

  final ClinicalService service;
  final bool green;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = green ? context.palette.positive : context.palette.accent;
    final background = green
        ? context.palette.tintGreen
        : context.palette.tintBlue;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: selected ? context.palette.accent : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: context.palette.elevated,
                child: Icon(_iconFor(service), color: tint),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: context.palette.ink,
                      ),
                    ),
                    if (service.description != null)
                      Text(
                        service.description!,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.palette.inkMuted,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      '${service.durationMinutes} min · ${service.priceLabel}',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: context.palette.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              _RadioCircle(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormatCard extends StatelessWidget {
  const _FormatCard({
    required this.background,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final Color background;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: selected ? context.palette.accent : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: context.palette.elevated,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const Spacer(),
                  _RadioCircle(selected: selected),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
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

class _RadioCircle extends StatelessWidget {
  const _RadioCircle({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? context.palette.accent : context.palette.line,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 11,
                height: 11,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.blue,
                ),
              ),
            )
          : null,
    );
  }
}
