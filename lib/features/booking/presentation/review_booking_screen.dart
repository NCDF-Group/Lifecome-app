import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/country/app_country.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_svg_icons.dart';
import '../../../core/widgets/design/soft_widgets.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../domain/booking_format.dart';
import '../domain/models/appointment.dart';

/// Blueprint views 15-16 — Review Booking & Payment / HMO Authorisation.
/// One screen, three designs depending on the booking:
///  * funded (HMO / benefits): "Confirm funded booking"
///  * in-person, pay per visit: "Review your appointment"
///  * online, pay per visit: "Review your payment"
///
/// No payment processor or eligibility backend is wired in yet, so paying
/// always "succeeds" after a short delay and funding stays "pending".
class ReviewBookingScreen extends ConsumerStatefulWidget {
  const ReviewBookingScreen({super.key, required this.selection});

  final BookingSelection selection;

  @override
  ConsumerState<ReviewBookingScreen> createState() =>
      _ReviewBookingScreenState();
}

class _ReviewBookingScreenState extends ConsumerState<ReviewBookingScreen> {
  String _patientName = 'You';
  bool _accepted = false;
  bool _priced = false;
  bool _loading = false;

  BookingSelection get _selection => widget.selection;
  bool get _funded => _selection.accessType == BookingAccessType.hmo;

  @override
  void initState() {
    super.initState();
    ref.read(sessionStoreProvider).read().then((session) {
      final name = session?.displayName;
      if (mounted && name != null && name.isNotEmpty) {
        setState(() => _patientName = name);
      }
    });
  }

  Future<void> _confirm() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _loading = false);
    context.push(RoutePaths.bookingConfirmation, extra: _selection);
  }

  void _comingSoon(String feature) =>
      showComingSoonPopup(context, feature: feature);

  @override
  Widget build(BuildContext context) {
    final country = ref.watch(countryProvider);
    final zone = timeZoneFor(country);
    final date = _selection.date ?? DateTime.now();
    final time = '${_selection.time ?? '10:30'} ($zone)';

    final String title;
    final String subtitle;
    final List<Widget> body;

    if (_funded) {
      title = 'Confirm funded booking';
      subtitle =
          'Check your funding details before confirming your appointment.';
      body = _fundedBody(date, time);
    } else if (_selection.isInPerson) {
      title = 'Review your appointment';
      subtitle = 'Please check your details before continuing.';
      body = _inPersonBody(date, time);
    } else {
      title = 'Review your payment';
      subtitle =
          'Please check your consultation details and payment information.';
      body = _onlineBody(country, date, time);
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            const DesignBackButton(),
            const SizedBox(height: 14),
            PageHeading(title, subtitle: subtitle),
            const SizedBox(height: 22),
            ...body,
          ],
        ),
      ),
    );
  }

  Widget _summaryHeader() => Row(
    children: [
      const IconCircle(glyph: AppSvgGlyph.videoBold, size: 50),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Online ${_selection.service?.title ?? 'GP consultation'}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Video consultation',
              style: TextStyle(
                fontSize: 14,
                letterSpacing: -0.3,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    ],
  );

  DetailRows _summaryCard(DateTime date, String time) => DetailRows(
    title: 'Consultation summary',
    header: _summaryHeader(),
    rows: [
      DetailRow(
        glyph: AppSvgGlyph.calendarBold,
        label: 'Date',
        value: formatFullDate(date),
      ),
      DetailRow(glyph: AppSvgGlyph.clockBold, label: 'Time', value: time),
    ],
  );

  List<Widget> _onlineBody(AppCountry country, DateTime date, String time) {
    final fee = _selection.service?.fee ?? 0;
    return [
      _summaryCard(date, time),
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Payment method',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.4,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE7E9ED)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  const _SelectedRadio(),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Self-pay (${currencyCode(country)})',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.4,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Text(
                        'Pay securely online',
                        style: TextStyle(
                          fontSize: 15,
                          letterSpacing: -0.3,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            _KeyValue(
              label: 'Consultation fee',
              value: _priced ? formatFee(country, fee) : 'Awaiting quote',
              labelMuted: true,
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE7E9ED)),
            _KeyValue(
              label: 'Total to pay',
              value: _priced ? formatFee(country, fee) : 'Not yet calculated',
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      SoftCard(
        radius: 12,
        onTap: () => _comingSoon('Payment information'),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: const Row(
          children: [
            AppSvgIcon(
              AppSvgGlyph.infoBold,
              size: 22,
              color: AppColors.actionBlue,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                'No payment taken until you approve the final price.',
                style: TextStyle(
                  fontSize: 15.5,
                  height: 1.35,
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
      const SizedBox(height: 24),
      PillButton(
        label: _priced ? 'Price confirmed' : 'Get price',
        outlined: true,
        height: 54,
        onPressed: _priced ? null : () => setState(() => _priced = true),
      ),
      const SizedBox(height: 12),
      _DisabledAwarePill(
        label: 'Pay and confirm booking',
        enabled: _priced && !_loading,
        loading: _loading,
        onPressed: _confirm,
      ),
      const SizedBox(height: 18),
      LinkRow(
        glyph: AppSvgGlyph.documentBold,
        title: 'Cancellation terms',
        onTap: () => _comingSoon('Cancellation terms'),
      ),
    ];
  }

  List<Widget> _inPersonBody(DateTime date, String time) {
    final city = _selection.location ?? 'London';
    return [
      DetailRows(
        rows: [
          DetailRow(
            glyph: AppSvgGlyph.userBold,
            label: 'Patient',
            value: '$_patientName (You)',
          ),
          DetailRow(
            glyph: AppSvgGlyph.stethoscope,
            label: 'Clinician',
            value: _selection.doctor?.name ?? 'Your GP',
            sub: _selection.doctor?.specialty ?? 'General practice',
          ),
          DetailRow(
            glyph: AppSvgGlyph.documentBold,
            label: 'Appointment type',
            value: 'In-person GP',
            sub: '$city Smart GP',
          ),
          DetailRow(
            glyph: AppSvgGlyph.calendarBold,
            label: 'Date',
            value: formatFullDate(date),
          ),
          DetailRow(glyph: AppSvgGlyph.clockBold, label: 'Time', value: time),
          DetailRow(
            glyph: AppSvgGlyph.pinBold,
            label: 'Location',
            value: '$city Smart GP',
            sub: 'View clinic details',
            onSubTap: () => _comingSoon('Clinic details'),
          ),
          const DetailRow(
            glyph: AppSvgGlyph.walletBold,
            label: 'Funding',
            value: 'Pay per visit',
            sub: 'Price shown before payment',
          ),
        ],
      ),
      const SizedBox(height: 28),
      SoftCard(
        radius: 12,
        onTap: () => _comingSoon('Cancellation terms'),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: const Row(
          children: [
            AppSvgIcon(
              AppSvgGlyph.infoBold,
              size: 22,
              color: AppColors.actionBlue,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.4,
                    color: AppColors.textPrimary,
                  ),
                  children: [
                    TextSpan(
                      text: 'You can cancel or change your booking.\nSee ',
                    ),
                    TextSpan(
                      text: 'cancellation terms.',
                      style: TextStyle(color: AppColors.actionBlue),
                    ),
                  ],
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
      const SizedBox(height: 28),
      InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => setState(() => _accepted = !_accepted),
        child: Row(
          children: [
            _Box(checked: _accepted),
            const SizedBox(width: 16),
            const Text(
              'I accept the booking terms',
              style: TextStyle(
                fontSize: 17,
                letterSpacing: -0.4,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      _DisabledAwarePill(
        label: 'Continue to payment',
        enabled: _accepted && !_loading,
        loading: _loading,
        onPressed: _confirm,
        activeBlue: true,
        onDisabledTap: () => showErrorPopup(
          context,
          'Please accept the booking terms to continue.',
        ),
      ),
    ];
  }

  List<Widget> _fundedBody(DateTime date, String time) {
    return [
      _summaryCard(date, time),
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF6FBF3),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            const IconCircle(
              glyph: AppSvgGlyph.briefcaseBold,
              color: AppColors.accentGreen,
              fill: Color(0xFFE2F2D6),
              size: 50,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selection.hmoName ?? 'LifeCome Benefits',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Row(
                    children: [
                      AppSvgIcon(
                        AppSvgGlyph.clockBold,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Eligibility check pending',
                        style: TextStyle(
                          fontSize: 15,
                          letterSpacing: -0.3,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const AppSvgIcon(
              AppSvgGlyph.infoBold,
              size: 22,
              color: AppColors.actionBlue,
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      const DetailRows(
        title: 'Funding details',
        rows: [
          DetailRow(
            glyph: AppSvgGlyph.documentBold,
            label: 'Service entitlement',
            value: 'Awaiting verification',
          ),
          DetailRow(
            glyph: AppSvgGlyph.walletBold,
            label: 'Remaining allowance',
            value: 'Awaiting verification',
          ),
          DetailRow(
            glyph: AppSvgGlyph.userBold,
            label: 'Patient contribution',
            value: 'Awaiting verification',
          ),
        ],
      ),
      const SizedBox(height: 24),
      const InfoNote('No booking confirmed until funding is resolved.'),
      const SizedBox(height: 24),
      PillButton(
        label: 'Check funding',
        height: 54,
        onPressed: () => _comingSoon('Funding check'),
      ),
      const SizedBox(height: 12),
      PillButton(
        label: 'Switch to self-pay',
        outlined: true,
        height: 54,
        onPressed: () => context.pushReplacement(
          RoutePaths.bookingReview,
          extra: _selection.copyWith(accessType: BookingAccessType.direct),
        ),
      ),
    ];
  }
}

class _KeyValue extends StatelessWidget {
  const _KeyValue({
    required this.label,
    required this.value,
    this.labelMuted = false,
  });

  final String label;
  final String value;
  final bool labelMuted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 17,
              fontWeight: labelMuted ? FontWeight.w400 : FontWeight.w600,
              letterSpacing: -0.4,
              color: labelMuted
                  ? AppColors.textSecondary
                  : AppColors.textPrimary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.4,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedRadio extends StatelessWidget {
  const _SelectedRadio();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.actionBlue, width: 1.6),
      ),
      child: const DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.actionBlue,
        ),
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: checked ? AppColors.actionBlue : AppColors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: checked ? AppColors.actionBlue : AppColors.textSecondary,
        ),
      ),
      child: checked
          ? const AppSvgIcon(
              AppSvgGlyph.checkLine,
              size: 20,
              color: AppColors.white,
            )
          : null,
    );
  }
}

/// Full-width pill that is blue when [enabled] and a flat grey otherwise
/// (the "Pay and confirm booking" look while the price is still unknown).
class _DisabledAwarePill extends StatelessWidget {
  const _DisabledAwarePill({
    required this.label,
    required this.enabled,
    required this.onPressed,
    this.loading = false,
    this.activeBlue = false,
    this.onDisabledTap,
  });

  final String label;
  final bool enabled;
  final bool loading;
  final VoidCallback onPressed;

  /// Keep the blue fill even when not yet enabled (it still validates on tap).
  final bool activeBlue;
  final VoidCallback? onDisabledTap;

  @override
  Widget build(BuildContext context) {
    final blue = enabled || activeBlue || loading;
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: FilledButton(
        onPressed: loading
            ? null
            : enabled
            ? onPressed
            : (onDisabledTap ?? () {}),
        style: FilledButton.styleFrom(
          backgroundColor: blue
              ? AppColors.actionBlue
              : const Color(0xFFB4BACB),
          foregroundColor: AppColors.white,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.3,
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label),
                  const SizedBox(width: 10),
                  const AppSvgIcon(AppSvgGlyph.chevronLine, size: 20),
                ],
              ),
      ),
    );
  }
}
