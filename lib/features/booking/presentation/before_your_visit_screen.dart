import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_svg_icons.dart';
import '../../../core/widgets/design/soft_widgets.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../domain/models/appointment.dart';

/// Blueprint view 14 — "Prepare for your clinic visit" / "Prepare for online
/// care": the clinical intake before a booking is reviewed. Which of the two
/// shows depends on the consultation type chosen earlier.
class BeforeYourVisitScreen extends StatefulWidget {
  const BeforeYourVisitScreen({super.key, required this.selection});

  final BookingSelection selection;

  @override
  State<BeforeYourVisitScreen> createState() => _BeforeYourVisitScreenState();
}

class _BeforeYourVisitScreenState extends State<BeforeYourVisitScreen> {
  final _reasonController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _medicinesController = TextEditingController();
  final _accessibilityController = TextEditingController();
  bool _understood = false;

  bool get _inPerson => widget.selection.consultationType == 'In-person visit';

  @override
  void dispose() {
    _reasonController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _medicinesController.dispose();
    _accessibilityController.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_inPerson && !_understood) {
      showErrorPopup(
        context,
        'Please tick "I understand the limits of remote assessment" to '
        'continue.',
      );
      return;
    }
    // Only what the patient actually filled in is kept and sent with the booking.
    final answers = <String, dynamic>{
      'reason': _reasonController.text.trim(),
      'medicinesAndAllergies': _medicinesController.text.trim(),
      if (_inPerson)
        'accessibilitySupport': _accessibilityController.text.trim()
      else ...{
        'patientLocation': _locationController.text.trim(),
        'callbackNumber': _phoneController.text.trim(),
        'understoodRemoteLimits': _understood,
      },
    }..removeWhere((_, value) => value == '');

    context.push(
      RoutePaths.bookingReview,
      extra: widget.selection.copyWith(
        concern: _reasonController.text.trim(),
        intake: answers,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            const DesignBackButton(),
            const SizedBox(height: 14),
            PageHeading(
              _inPerson
                  ? 'Prepare for your clinic visit'
                  : 'Prepare for online care',
              subtitle:
                  'Help your clinician get the right information so you can '
                  'receive the best possible care.',
            ),
            const SizedBox(height: 22),
            if (_inPerson) ...[
              _PrepareCard(
                glyph: AppSvgGlyph.buildingBold,
                title: 'Mode of appointment',
                lines: [
                  const _Line('In person', dark: true),
                  _Line(widget.selection.location ?? 'Lagos'),
                ],
              ),
              _PrepareCard(
                glyph: AppSvgGlyph.documentBold,
                title: 'Symptoms',
                lines: const [_Line('What would you like to discuss?')],
                controller: _reasonController,
                hint: 'e.g. new symptoms, ongoing condition',
              ),
              _PrepareCard(
                glyph: AppSvgGlyph.pillsBold,
                title: 'Medicines and allergies',
                lines: const [
                  _Line('List your current medicines and any allergies.'),
                ],
                controller: _medicinesController,
                hint: 'e.g. paracetamol, penicillin (allergy)',
              ),
              _PrepareCard(
                glyph: AppSvgGlyph.accessibilityBold,
                title: 'Accessibility support',
                lines: const [_Line('Do you need any additional support?')],
                controller: _accessibilityController,
                hint: 'e.g. wheelchair access, interpreter',
              ),
              const _PrepareCard(
                glyph: AppSvgGlyph.idCardBold,
                title: 'Bring ID and relevant records',
                lines: [
                  _Line(
                    'Please bring a valid ID and any relevant medical records '
                    'to your appointment.',
                  ),
                ],
              ),
            ] else ...[
              _PrepareCard(
                glyph: AppSvgGlyph.documentBold,
                title: 'Reason for visit',
                lines: const [_Line('What would you like to discuss?')],
                controller: _reasonController,
                hint: 'e.g. new symptoms, medication review',
              ),
              _PrepareCard(
                glyph: AppSvgGlyph.pinBold,
                title: 'Your actual location at appointment',
                lines: const [
                  _Line('Where will you be during the appointment?'),
                ],
                controller: _locationController,
                hint: 'e.g. home, work or other location',
              ),
              _PrepareCard(
                glyph: AppSvgGlyph.phoneBold,
                title: 'Callback number',
                lines: const [
                  _Line('A number the clinician can call if needed.'),
                ],
                controller: _phoneController,
                hint: 'e.g. 07XX XXX XXXX',
                keyboardType: TextInputType.phone,
              ),
              _PrepareCard(
                glyph: AppSvgGlyph.pillsBold,
                title: 'Medicines and allergies',
                lines: const [
                  _Line('List your current medicines and any allergies.'),
                ],
                controller: _medicinesController,
                hint: 'e.g. paracetamol, penicillin (allergy)',
              ),
              const SizedBox(height: 12),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => setState(() => _understood = !_understood),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: _understood
                            ? AppColors.actionBlue
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: _understood
                              ? AppColors.actionBlue
                              : AppColors.textSecondary,
                        ),
                      ),
                      child: _understood
                          ? const AppSvgIcon(
                              AppSvgGlyph.checkLine,
                              size: 18,
                              color: AppColors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'I understand the limits of remote assessment.',
                        style: TextStyle(
                          fontSize: 15.5,
                          letterSpacing: -0.3,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 28),
            SoftCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const IconCircle(
                        glyph: AppSvgGlyph.infoBold,
                        size: 50,
                        iconSize: 22,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          _inPerson
                              ? 'Clinic details will appear once your '
                                    'appointment is confirmed.'
                              : 'An in-person assessment may be recommended '
                                    'after reviewing your information.',
                          style: const TextStyle(
                            fontSize: 17,
                            height: 1.35,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.4,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  PillButton(
                    label: _inPerson ? 'Review appointment' : 'Continue',
                    onPressed: _continue,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () => showComingSoonPopup(
                context,
                feature: 'Emergency and urgent help',
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    AppSvgIcon(
                      AppSvgGlyph.arrowSquareBold,
                      size: 24,
                      color: AppColors.actionBlue,
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        'Emergency and urgent help',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.4,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    AppSvgIcon(
                      AppSvgGlyph.chevronLine,
                      size: 22,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Line {
  const _Line(this.text, {this.dark = false});

  final String text;

  /// A value (shown dark) rather than a hint (grey).
  final bool dark;
}

/// A white bordered intake card: icon, title, grey hint lines, optional text
/// field, and a chevron at the top right.
class _PrepareCard extends StatelessWidget {
  const _PrepareCard({
    required this.glyph,
    required this.title,
    required this.lines,
    this.controller,
    this.hint,
    this.keyboardType,
  });

  final AppSvgGlyph glyph;
  final String title;
  final List<_Line> lines;
  final TextEditingController? controller;
  final String? hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 32,
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: AppSvgIcon(glyph, size: 26, color: AppColors.actionBlue),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.4,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  for (final line in lines)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        line.text,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.35,
                          letterSpacing: -0.3,
                          color: line.dark
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  if (controller != null) ...[
                    const SizedBox(height: 6),
                    TextField(
                      controller: controller,
                      keyboardType: keyboardType,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: hint,
                        hintStyle: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 16,
                        ),
                        border: _border(AppColors.cardBorder),
                        enabledBorder: _border(AppColors.cardBorder),
                        focusedBorder: _border(AppColors.actionBlue),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: AppSvgIcon(
                AppSvgGlyph.chevronLine,
                size: 22,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: color),
  );
}
