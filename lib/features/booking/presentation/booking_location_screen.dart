import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/max_content_width.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../profile/application/profile_controller.dart';
import '../domain/models/booking_selection.dart';
import '../domain/models/consultation_mode.dart';

/// Between choosing a service and finding a clinician: where the patient will
/// be (for an online visit) or wants a clinic (for an in-person one). The
/// answer travels with the booking — it is sent to the care team as part of
/// the visit details, and it narrows the clinics shown for an in-person visit.
class BookingLocationScreen extends ConsumerStatefulWidget {
  const BookingLocationScreen({super.key, required this.selection});

  final BookingSelection selection;

  @override
  ConsumerState<BookingLocationScreen> createState() =>
      _BookingLocationScreenState();
}

class _BookingLocationScreenState extends ConsumerState<BookingLocationScreen> {
  final _cityController = TextEditingController();
  final _postcodeController = TextEditingController();
  String? _cityError;
  String? _postcodeError;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _cityController.text = widget.selection.city ?? '';
    _postcodeController.text = widget.selection.postcode ?? '';
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
    if (!_validate()) return;

    final selection = widget.selection.copyWith(
      city: _cityController.text.trim(),
      postcode: _postcodeController.text.trim().toUpperCase(),
    );
    // Arriving from the clinic finder the clinician is already chosen, so go
    // straight to their times.
    if (selection.doctor != null) {
      context.push(RoutePaths.bookingAppointmentTime, extra: selection);
    } else {
      context.push(RoutePaths.doctorsFindADoctor, extra: selection);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inPerson = widget.selection.mode == ConsultationMode.inPerson;

    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: MaxContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppHeaderBar(showBack: true, showBell: false),
                const SizedBox(height: AppSpacing.lg),
                ScreenTitle(
                  title: inPerson
                      ? 'Where do you want a clinic?'
                      : 'Where will you be?',
                  subtitle: inPerson
                      ? 'We will show clinics in this area first.'
                      : 'Your clinician needs to know where you are during '
                            'the appointment.',
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'Town or city',
                  controller: _cityController,
                  textInputAction: TextInputAction.next,
                  errorText: _cityError,
                  onChanged: (_) => _revalidate(),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Postcode',
                  controller: _postcodeController,
                  hintText: 'e.g. SW1A 1AA',
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.characters,
                  errorText: _postcodeError,
                  onChanged: (_) => _revalidate(),
                  onSubmitted: (_) => _continue(),
                ),
                const SizedBox(height: AppSpacing.md),
                const InfoBanner(
                  message:
                      'Availability depends on your location.\nIf care is '
                      'unavailable, choose another location or contact '
                      'support.',
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: 'Check availability',
                  icon: Icons.arrow_forward,
                  onPressed: _continue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
