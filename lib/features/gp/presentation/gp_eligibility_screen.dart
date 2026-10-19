import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/buttons/ghost_button.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/inputs/choice_card.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/max_content_width.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/layout/step_progress.dart';
import '../../booking/domain/models/booking_selection.dart';
import '../../booking/domain/models/consultation_mode.dart';
import '../../profile/application/profile_controller.dart';

/// "Before you book" — step 1 of the GP booking (screen pack 038): who the
/// appointment is for, where the patient will be (or wants a clinic), and
/// that this is routine care, not an emergency. The place travels with the
/// booking to the care team, so the later location step is skipped.
class GpEligibilityScreen extends ConsumerStatefulWidget {
  const GpEligibilityScreen({super.key, required this.start});

  final BookingStart start;

  @override
  ConsumerState<GpEligibilityScreen> createState() =>
      _GpEligibilityScreenState();
}

class _GpEligibilityScreenState extends ConsumerState<GpEligibilityScreen> {
  final _cityController = TextEditingController();
  final _postcodeController = TextEditingController();
  String? _cityError;
  String? _postcodeError;
  bool _notEmergency = false;
  bool _submitted = false;

  bool get _inPerson => widget.start.mode == ConsultationMode.inPerson;

  @override
  void initState() {
    super.initState();
    // Start from the town on the person's profile, if they gave one.
    ref.listenManual(meProvider, (_, next) {
      final city = next.value?.profile?.city;
      if (city != null && _cityController.text.isEmpty) {
        _cityController.text = city;
      }
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _cityController.dispose();
    _postcodeController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _cityError = Validators.place(
        _cityController.text,
        label: 'town or city',
        required: true,
      );
      _postcodeError = Validators.ukPostcode(_postcodeController.text);
    });
    return _cityError == null && _postcodeError == null;
  }

  void _revalidate() {
    if (_submitted) _validate();
  }

  void _continue() {
    setState(() => _submitted = true);
    if (!_validate() || !_notEmergency) return;

    final city = _cityController.text.trim();
    final postcode = _postcodeController.text.trim().toUpperCase();
    final start = widget.start;
    final next = start.plan == null
        ? BookingStart.direct(mode: start.mode, city: city, postcode: postcode)
        : BookingStart.hmo(
            start.plan!,
            mode: start.mode,
            city: city,
            postcode: postcode,
          );
    if (_inPerson) {
      context.push(RoutePaths.findSmartGpClinic, extra: next);
    } else {
      context.push(RoutePaths.bookingChooseService, extra: next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    Widget label(String text) => Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: palette.ink,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 25),
          child: MaxContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppHeaderBar(showBack: true, backFallback: RoutePaths.gp),
                const StepProgress(step: 1, total: 6),
                const ScreenTitle(
                  title: 'Before you book',
                  subtitle:
                      'A few details to guide you to the right appointment.',
                ),
                label('Who is the appointment for?'),
                ChoiceCard(
                  title: 'Myself',
                  subtitle: 'Age 18 or over',
                  selected: true,
                  onTap: () {},
                ),
                label(
                  _inPerson
                      ? 'Where do you want a clinic?'
                      : 'Where will you be during the appointment?',
                ),
                AppTextField(
                  label: 'Town or city',
                  controller: _cityController,
                  textInputAction: TextInputAction.next,
                  errorText: _cityError,
                  onChanged: (_) => _revalidate(),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Postcode',
                  controller: _postcodeController,
                  hintText: 'e.g. SW1A 1AA',
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.characters,
                  errorText: _postcodeError,
                  onChanged: (_) => _revalidate(),
                ),
                const SizedBox(height: 8),
                CheckRow(
                  value: _notEmergency,
                  onChanged: (value) => setState(() => _notEmergency = value),
                  label:
                      'I understand this is a routine appointment and not '
                      'emergency care.',
                ),
                if (_submitted && !_notEmergency)
                  Padding(
                    padding: const EdgeInsets.only(left: 30, bottom: 6),
                    child: Text(
                      'Please confirm this is not an emergency.',
                      style: TextStyle(fontSize: 12.5, color: palette.danger),
                    ),
                  ),
                const SizedBox(height: 6),
                const InfoBanner(
                  message:
                      'LifeCome GP care is for adults in the United Kingdom. '
                      'Availability depends on where you are.',
                ),
                const SizedBox(height: 16),
                PrimaryButton(label: 'Continue', onPressed: _continue),
                const SizedBox(height: 6),
                GhostButton(
                  label: 'I need urgent help',
                  onPressed: () => context.push(RoutePaths.emergency),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
