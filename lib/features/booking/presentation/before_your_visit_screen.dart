import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/inputs/choice_card.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/layout/step_progress.dart';
import '../../../core/widgets/layout/max_content_width.dart';
import '../../profile/application/profile_controller.dart';
import '../../profile/data/health_profile_store.dart';
import '../domain/models/appointment.dart';
import '../domain/models/booking_selection.dart';
import '../domain/models/consultation_mode.dart';

const _durations = [
  'Less than a day',
  'A few days',
  'About a week',
  'More than a week',
];

/// Blueprint view 14 — Before Your Visit (clinical intake). What is entered
/// here is sent with the booking, so the clinician can prepare.
class BeforeYourVisitScreen extends ConsumerStatefulWidget {
  const BeforeYourVisitScreen({super.key, required this.selection});

  final BookingSelection selection;

  @override
  ConsumerState<BeforeYourVisitScreen> createState() =>
      _BeforeYourVisitScreenState();
}

class _BeforeYourVisitScreenState extends ConsumerState<BeforeYourVisitScreen> {
  final _concernController = TextEditingController();
  final _medicinesController = TextEditingController();
  final _accessibilityController = TextEditingController();
  final _callbackController = TextEditingController();
  final _locationController = TextEditingController();

  String _duration = _durations.first;
  bool _consented = false;
  bool _submitted = false;

  String? _concernError;
  String? _medicinesError;
  String? _accessibilityError;
  String? _callbackError;
  String? _locationError;
  String? _consentError;

  bool get _online => widget.selection.mode.isOnline;

  /// A phone number is needed to ring the patient for a telephone consultation.
  bool get _callbackRequired => widget.selection.mode == ConsultationMode.audio;

  @override
  void initState() {
    super.initState();
    final selection = widget.selection;
    _concernController.text = selection.concern ?? '';
    _locationController.text = [
      ?selection.city,
      ?selection.postcode,
    ].join(', ');
    // Offer what the health profile says about medicines and allergies.
    ref.listenManual(healthProfileProvider, (_, next) {
      final noted = next.value?.medicinesAndAllergies;
      if (noted != null && _medicinesController.text.isEmpty) {
        _medicinesController.text = noted;
      }
    }, fireImmediately: true);
    // Offer the number on the account to be rung on; the person can change it.
    ref.listenManual(meProvider, (_, next) {
      final phone = next.value?.account.phoneNumber;
      if (phone != null && _callbackController.text.isEmpty) {
        _callbackController.text = Formatters.ukPhone(phone);
      }
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _concernController.dispose();
    _medicinesController.dispose();
    _accessibilityController.dispose();
    _callbackController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _concernError = Validators.text(
        _concernController.text,
        label: 'what you would like to discuss',
        required: true,
        minLength: 10,
      );
      _medicinesError = Validators.text(
        _medicinesController.text,
        label: 'your medicines and allergies',
      );
      _accessibilityError = Validators.text(
        _accessibilityController.text,
        label: 'the support you need',
        maxLength: 1000,
      );
      _callbackError = Validators.ukPhone(
        _callbackController.text,
        required: _callbackRequired,
      );
      _locationError = _online
          ? Validators.text(
              _locationController.text,
              label: 'where you will be',
              maxLength: 500,
            )
          : null;
      _consentError = _online && !_consented
          ? 'Please confirm to continue.'
          : null;
    });
    return [
      _concernError,
      _medicinesError,
      _accessibilityError,
      _callbackError,
      _locationError,
      _consentError,
    ].every((error) => error == null);
  }

  void _revalidate() {
    if (_submitted) _validate();
  }

  String? _optional(TextEditingController controller) {
    final text = controller.text.trim();
    return text.isEmpty ? null : text;
  }

  void _continue() {
    setState(() => _submitted = true);
    if (!_validate()) return;

    final concern = _concernController.text.trim();
    context.push(
      RoutePaths.bookingReview,
      extra: widget.selection.copyWith(
        concern: concern,
        intake: AppointmentIntake(
          reason: '$concern\n\nHow long: ${_duration.toLowerCase()}.',
          medicinesAndAllergies: _optional(_medicinesController),
          accessibilitySupport: _optional(_accessibilityController),
          callbackNumber: Validators.normalizeUkPhone(_callbackController.text),
          patientLocation: _online ? _optional(_locationController) : null,
          understoodRemoteLimits: _online ? true : null,
        ),
      ),
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
            MaxContentWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppHeaderBar(
                    showBack: true,
                    backFallback: RoutePaths.gp,
                  ),
                  const StepProgress(step: 5, total: 6),
                  const ScreenTitle(
                    title: 'Help your GP prepare',
                    subtitle: 'A few details before your consultation.',
                  ),
                  const SizedBox(height: 18),
                  _MultilineField(
                    label: 'What would you like to discuss?',
                    hint: 'Briefly describe your concern',
                    controller: _concernController,
                    errorText: _concernError,
                    onChanged: (_) => _revalidate(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'How long has this been happening?',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: context.palette.ink,
                    ),
                  ),
                  const SizedBox(height: 7),
                  DropdownButtonFormField<String>(
                    initialValue: _duration,
                    items: [
                      for (final duration in _durations)
                        DropdownMenuItem(
                          value: duration,
                          child: Text(duration),
                        ),
                    ],
                    onChanged: (value) =>
                        setState(() => _duration = value ?? _duration),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.control),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _MultilineField(
                    label: 'Medicines and allergies (optional)',
                    hint: 'Anything you take regularly, and any allergies',
                    controller: _medicinesController,
                    errorText: _medicinesError,
                    maxLines: 3,
                    onChanged: (_) => _revalidate(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _MultilineField(
                    label: 'Support you need (optional)',
                    hint: 'For example hearing, sight or mobility support',
                    controller: _accessibilityController,
                    errorText: _accessibilityError,
                    maxLines: 2,
                    onChanged: (_) => _revalidate(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: _callbackRequired
                        ? 'Phone number to call you on'
                        : 'Phone number if the call drops (optional)',
                    controller: _callbackController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    errorText: _callbackError,
                    onChanged: (_) => _revalidate(),
                  ),
                  if (_online) ...[
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Where will you be? (optional)',
                      controller: _locationController,
                      textInputAction: TextInputAction.done,
                      errorText: _locationError,
                      onChanged: (_) => _revalidate(),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    CheckRow(
                      value: _consented,
                      onChanged: (value) {
                        setState(() => _consented = value);
                        _revalidate();
                      },
                      label:
                          'I agree to an online consultation and understand it '
                          'may not be suitable for every concern.',
                    ),
                    if (_consentError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Text(
                          _consentError!,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.palette.danger,
                          ),
                        ),
                      ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(label: 'Continue', onPressed: _continue),
                  const SizedBox(height: AppSpacing.xs),
                  Center(
                    child: Text(
                      'Your GP will review these details.',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.palette.inkMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A labelled multi-line text box with the app's field styling and an error
/// line, for the free-text answers.
class _MultilineField extends StatelessWidget {
  const _MultilineField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.onChanged,
    this.errorText,
    this.maxLines = 4,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final int maxLines;
  final String? errorText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: context.palette.ink,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          maxLines: maxLines,
          minLines: maxLines > 2 ? 3 : 2,
          onChanged: onChanged,
          style: TextStyle(fontSize: 16, color: context.palette.ink),
          decoration: InputDecoration(hintText: hint, errorText: errorText),
        ),
      ],
    );
  }
}
