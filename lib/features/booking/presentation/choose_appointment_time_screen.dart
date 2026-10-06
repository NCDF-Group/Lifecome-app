import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/country/app_country.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_svg_icons.dart';
import '../../../core/widgets/design/soft_widgets.dart';
import '../domain/booking_format.dart';
import '../domain/models/appointment.dart';

const _times = ['09:00', '10:30', '14:00'];

/// Blueprint view 13 — "Choose your appointment": Online / In Person, the
/// clinic (for in-person), a date, and one of the available times.
class ChooseAppointmentTimeScreen extends ConsumerStatefulWidget {
  const ChooseAppointmentTimeScreen({super.key, required this.selection});

  final BookingSelection selection;

  @override
  ConsumerState<ChooseAppointmentTimeScreen> createState() =>
      _ChooseAppointmentTimeScreenState();
}

class _ChooseAppointmentTimeScreenState
    extends ConsumerState<ChooseAppointmentTimeScreen> {
  late bool _inPerson = widget.selection.isInPerson;
  late DateTime _date = DateTime.now().add(const Duration(days: 1));
  String _time = _times[1];

  String get _city =>
      widget.selection.location ??
      (ref.read(countryProvider) == AppCountry.unitedKingdom
          ? 'London'
          : 'Lagos');

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: today,
      lastDate: today.add(const Duration(days: 60)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _continue() {
    context.push(
      RoutePaths.bookingBeforeYourVisit,
      extra: widget.selection.copyWith(
        consultationType: _inPerson ? 'In-person visit' : 'Video consultation',
        location: _city,
        date: _date,
        time: _time,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final zone = timeZoneFor(ref.watch(countryProvider));

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            const DesignBackButton(),
            const SizedBox(height: 14),
            const PageHeading(
              'Choose your appointment',
              subtitle:
                  'Select how you would like to be seen and pick a date and '
                  'time',
            ),
            const SizedBox(height: 22),
            SlidingSegments(
              items: const [
                SegmentItem('Online', glyph: AppSvgGlyph.videoBold),
                SegmentItem('In Person', glyph: AppSvgGlyph.pinBold),
              ],
              selected: _inPerson ? 1 : 0,
              onChanged: (index) => setState(() => _inPerson = index == 1),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: _inPerson
                  ? Padding(
                      padding: const EdgeInsets.only(top: 22),
                      child: SoftCard(
                        radius: 12,
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            const IconCircle(
                              glyph: AppSvgGlyph.pinBold,
                              size: 50,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$_city Smart GP',
                                    style: const TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'In person appointments at a $_city '
                                    'location',
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      letterSpacing: -0.3,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 58,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    const AppSvgIcon(
                      AppSvgGlyph.calendarBold,
                      size: 24,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'Select a date',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.4,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      formatShortDate(_date),
                      style: const TextStyle(
                        fontSize: 16,
                        letterSpacing: -0.3,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const AppSvgIcon(
                      AppSvgGlyph.chevronDown,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: Row(
                      children: [
                        AppSvgIcon(
                          AppSvgGlyph.clockBold,
                          size: 24,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 14),
                        Text(
                          'Available times',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.4,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFE7E9ED),
                  ),
                  for (final time in _times)
                    InkWell(
                      onTap: () => setState(() => _time = time),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        child: Row(
                          children: [
                            _RadioDot(selected: time == _time),
                            const SizedBox(width: 14),
                            Text(
                              time,
                              style: const TextStyle(
                                fontSize: 18,
                                letterSpacing: -0.4,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            const SizedBox(height: 24),
            InfoNote('Times shown in $zone', centerIcon: true),
            const SizedBox(height: 24),
            PillButton(label: 'Continue', height: 58, onPressed: _continue),
          ],
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 28,
      height: 28,
      padding: const EdgeInsets.all(3.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.actionBlue : AppColors.textSecondary,
          width: selected ? 1.6 : 1,
        ),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? AppColors.actionBlue : Colors.transparent,
        ),
      ),
    );
  }
}
