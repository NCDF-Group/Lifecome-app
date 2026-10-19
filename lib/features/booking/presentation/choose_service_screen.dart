import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/feedback/empty_state.dart';
import '../../../core/widgets/feedback/error_state.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/feedback/loading_indicator.dart';
import '../../../core/widgets/inputs/choice_card.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/layout/section_header.dart';
import '../../../core/widgets/layout/step_progress.dart';
import '../../payer/application/payer_controller.dart';
import '../../payer/presentation/widgets/cover_badge.dart';
import '../application/booking_controller.dart';
import '../domain/models/booking_selection.dart';
import '../domain/models/clinical_service.dart';
import '../domain/models/consultation_mode.dart';

/// "What can we help with?" — step 2 of the GP booking (the screen pack's
/// 039), and the first screen of the health-plan path. The reasons are the
/// backend's clinical services, with their prices.
///
/// Started from the GP hub the visit type is already chosen; otherwise (the
/// health-plan path) this screen also asks online or in-clinic.
class ChooseServiceScreen extends ConsumerStatefulWidget {
  const ChooseServiceScreen({super.key, required this.start});

  final BookingStart start;

  @override
  ConsumerState<ChooseServiceScreen> createState() =>
      _ChooseServiceScreenState();
}

class _ChooseServiceScreenState extends ConsumerState<ChooseServiceScreen> {
  String? _selectedId;
  late ConsultationMode _mode = widget.start.mode ?? ConsultationMode.video;

  bool get _isHmo => widget.start.accessType == BookingAccessType.hmo;

  /// Started from the clinic finder: the clinician and the visit type are
  /// already decided.
  bool get _clinicianChosen => widget.start.doctor != null;

  /// The GP hub or clinic finder already said online or in-clinic.
  bool get _modeChosen => _clinicianChosen || widget.start.mode != null;

  ClinicalService? _selected(List<ClinicalService> services) {
    if (services.isEmpty) return null;
    for (final service in services) {
      if (service.id == _selectedId) return service;
    }
    return services.first;
  }

  void _continue(ClinicalService service, ServiceCoverage? coverage) {
    final start = widget.start;
    final doctor = start.doctor;
    final selection = BookingSelection(
      accessType: start.accessType,
      plan: start.plan,
      eligibility: coverage?.check,
      service: service,
      doctor: doctor,
      mode: _clinicianChosen ? ConsultationMode.inPerson : _mode,
      city: start.city,
      postcode: start.postcode,
    );
    // The eligibility step already asked where the patient will be.
    if (start.city == null) {
      context.push(RoutePaths.bookingLocation, extra: selection);
    } else if (doctor != null) {
      context.push(RoutePaths.bookingAppointmentTime, extra: selection);
    } else {
      context.push(RoutePaths.doctorsFindADoctor, extra: selection);
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = ref.watch(clinicalServicesProvider);
    final selected = services.hasValue
        ? _selected(services.requireValue)
        : null;

    // With a health plan paying, each service shows what the plan says.
    final plan = widget.start.plan;
    final coverage = plan == null
        ? null
        : ref.watch(serviceCoverageProvider(plan.membership.id));
    ServiceCoverage? coverageOf(ClinicalService? service) {
      if (service == null) return null;
      for (final item in coverage?.value ?? const <ServiceCoverage>[]) {
        if (item.service.id == service.id) return item;
      }
      return null;
    }

    final selectedCoverage = coverageOf(selected);
    final coverageLoading = coverage?.isLoading ?? false;
    // A plan that will not pay for a service cannot be used to book it.
    final planWillNotPay =
        plan != null &&
        selected != null &&
        !coverageLoading &&
        !(selectedCoverage?.check?.status.isBookable ?? false);

    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
                  const AppHeaderBar(
                    showBack: true,
                    backFallback: RoutePaths.gp,
                  ),
                  const StepProgress(step: 2, total: 6),
                  const ScreenTitle(
                    title: 'What can we help with?',
                    subtitle:
                        'Choose the closest match. You can tell your GP more '
                        'before the appointment.',
                  ),
                  const SizedBox(height: 14),
                  if (_isHmo && widget.start.hmoName != null) ...[
                    InfoBanner(
                      tone: BannerTone.success,
                      icon: Icons.health_and_safety_outlined,
                      message: 'Access: ${widget.start.hmoName}',
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (_clinicianChosen) ...[
                    InfoBanner(
                      icon: Icons.apartment_outlined,
                      message:
                          'In-person appointment with ${widget.start.doctor!.name}.',
                    ),
                    const SizedBox(height: 10),
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
                              for (final service in list)
                                ChoiceCard(
                                  title: service.title,
                                  subtitle: [
                                    ?service.description,
                                    '${service.durationMinutes} min',
                                  ].join(' · '),
                                  selected: service.id == selected?.id,
                                  trailing: Text(
                                    service.priceLabel,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: context.palette.ink,
                                    ),
                                  ),
                                  footer: plan == null
                                      ? null
                                      : CoverBadge(
                                          loading: coverageLoading,
                                          coverage: coverageOf(service),
                                        ),
                                  onTap: () =>
                                      setState(() => _selectedId = service.id),
                                ),
                            ],
                          ),
                  ),
                  if (plan != null && planWillNotPay) ...[
                    const SizedBox(height: 10),
                    InfoBanner(
                      tone: BannerTone.warning,
                      title: "${plan.name} won't pay for this",
                      message:
                          selectedCoverage?.check?.status.label ??
                          "We couldn't check your cover for this service.",
                      actionLabel: 'Pay for it myself instead',
                      onAction: () => context.push(
                        RoutePaths.bookingChooseService,
                        extra: const BookingStart.direct(),
                      ),
                    ),
                  ],
                  if (!_modeChosen && services.hasValue) ...[
                    const SectionHeader(
                      title: 'How would you like to be seen?',
                    ),
                    const SizedBox(height: 6),
                    ChoiceCard(
                      title: 'Online GP',
                      subtitle: 'Speak to a GP by video',
                      selected: _mode.isOnline,
                      onTap: () =>
                          setState(() => _mode = ConsultationMode.video),
                    ),
                    ChoiceCard(
                      title: 'In-clinic GP',
                      subtitle: 'See a GP in person',
                      selected: !_mode.isOnline,
                      onTap: () =>
                          setState(() => _mode = ConsultationMode.inPerson),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: PrimaryButton(
                label: 'Continue',
                onPressed: selected == null || planWillNotPay || coverageLoading
                    ? null
                    : () => _continue(selected, selectedCoverage),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
