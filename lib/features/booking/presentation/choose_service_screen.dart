import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../domain/models/appointment.dart';
import '../domain/models/clinical_service.dart';

const _serviceIcons = {
  'gp-consultation': Icons.workspace_premium_outlined,
  'follow-up': Icons.calendar_month_outlined,
  'results-review': Icons.description_outlined,
  'referral-advice': Icons.person_outline,
};

enum _AppointmentFormat { online, clinic }

/// Blueprint views 09 (Check Service Eligibility, HMO path) and 10 (Choose a
/// Service, direct-pay path) — the same underlying choice, so one screen
/// serves both, showing coverage badges only when booking through an HMO.
class ChooseServiceScreen extends StatefulWidget {
  const ChooseServiceScreen({
    super.key,
    required this.accessType,
    this.hmoName,
  });

  final BookingAccessType accessType;
  final String? hmoName;

  @override
  State<ChooseServiceScreen> createState() => _ChooseServiceScreenState();
}

class _ChooseServiceScreenState extends State<ChooseServiceScreen> {
  ClinicalService _selected = clinicalServices.first;
  _AppointmentFormat _format = _AppointmentFormat.online;

  bool get _isHmo => widget.accessType == BookingAccessType.hmo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  AppHeaderBar(showBack: true, onBack: () => context.pop()),
                  const SizedBox(height: 20),
                  const Text(
                    'What care do you need?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Choose a service to get started. Services depend on '
                    'your location and availability.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.inkMuted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (_isHmo && widget.hmoName != null)
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF7E8),
                        borderRadius: BorderRadius.circular(AppRadius.control),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.health_and_safety_outlined,
                            color: AppColors.greenStrong,
                            size: 18,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'Access: ${widget.hmoName}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  for (var i = 0; i < clinicalServices.length; i++) ...[
                    _ServiceTile(
                      service: clinicalServices[i],
                      green: i.isEven,
                      selected: clinicalServices[i].id == _selected.id,
                      isHmo: _isHmo,
                      onTap: () =>
                          setState(() => _selected = clinicalServices[i]),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  const SizedBox(height: AppSpacing.xs),
                  const Text(
                    'How would you like to have your appointment?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const Text(
                    'Choose one option.',
                    style: TextStyle(fontSize: 13, color: AppColors.inkMuted),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _FormatCard(
                            background: const Color(0xFFEAF7E8),
                            iconColor: AppColors.greenStrong,
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
                            background: const Color(0xFFE3EEFB),
                            iconColor: AppColors.blue,
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
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: PrimaryButton(
                label: 'Continue',
                icon: Icons.arrow_forward,
                onPressed: () => context.push(
                  RoutePaths.bookingLocation,
                  extra: BookingSelection(
                    accessType: widget.accessType,
                    hmoName: widget.hmoName,
                    service: _selected,
                    consultationType: _format == _AppointmentFormat.online
                        ? 'Video consultation'
                        : 'In-person consultation',
                  ),
                ),
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
    required this.isHmo,
    required this.onTap,
  });

  final ClinicalService service;
  final bool green;
  final bool selected;
  final bool isHmo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = green ? AppColors.greenStrong : AppColors.blue;
    final background = green
        ? const Color(0xFFEAF7E8)
        : const Color(0xFFE3EEFB);

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
              color: selected ? AppColors.blue : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.white,
                child: Icon(
                  _serviceIcons[service.id] ?? Icons.medical_services_outlined,
                  color: tint,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      service.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.inkMuted,
                      ),
                    ),
                    if (isHmo) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (service.requiresAuthorisation
                                      ? AppColors.gold
                                      : AppColors.greenStrong)
                                  .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          service.requiresAuthorisation
                              ? 'Requires authorisation'
                              : 'Covered',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: service.requiresAuthorisation
                                ? AppColors.gold
                                : AppColors.greenStrong,
                          ),
                        ),
                      ),
                    ],
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
              color: selected ? AppColors.blue : Colors.transparent,
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
                      color: AppColors.white,
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
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: AppColors.inkMuted),
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
          color: selected ? AppColors.blue : AppColors.line,
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
