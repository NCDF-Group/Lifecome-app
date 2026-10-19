import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/idempotency_key_generator.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/inputs/choice_card.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/detail_list.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/layout/step_progress.dart';
import '../../../core/widgets/layout/max_content_width.dart';
import '../../payer/domain/models/eligibility_status.dart';
import '../application/booking_controller.dart';
import '../../profile/presentation/profile_required_prompt.dart';
import '../domain/models/booking_selection.dart';
import '../domain/models/consultation_mode.dart';

/// "Review your appointment" — step 6 of the GP booking (screen pack 047
/// and 048 merged): what will be booked and how it is paid for; confirming
/// creates the appointment on the backend.
class ReviewBookingScreen extends ConsumerStatefulWidget {
  const ReviewBookingScreen({super.key, required this.selection});

  final BookingSelection selection;

  @override
  ConsumerState<ReviewBookingScreen> createState() =>
      _ReviewBookingScreenState();
}

class _ReviewBookingScreenState extends ConsumerState<ReviewBookingScreen> {
  bool _agreed = false;
  bool _showAgreeError = false;
  bool _loading = false;

  /// One set of keys for this screen: tapping "Confirm" again after a dropped
  /// connection repeats the same request and can never book twice.
  final _keys = BookingAttemptKeys(
    create: newIdempotencyKey(),
    payment: newIdempotencyKey(),
    confirm: newIdempotencyKey(),
    authorisation: newIdempotencyKey(),
  );

  Future<void> _confirm() async {
    if (_loading) return;
    if (!_agreed) {
      setState(() => _showAgreeError = true);
      return;
    }
    setState(() => _loading = true);
    try {
      final outcome = await ref
          .read(bookingControllerProvider)
          .submit(widget.selection, _keys);
      if (!mounted) return;
      // Land on My Visits, with the confirmation on top of it, so back from
      // the confirmation never returns to a booking that has been made.
      context.go(RoutePaths.visits);
      context.push(RoutePaths.bookingConfirmation, extra: outcome);
    } on ApiException catch (error) {
      if (!mounted) return;
      await _showFailure(error);
    } catch (_) {
      if (!mounted) return;
      await showErrorPopup(context, 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showFailure(ApiException error) async {
    switch (error.code) {
      case 'SLOT_UNAVAILABLE' || 'SLOT_IN_PAST':
        await showErrorPopup(context, error.message);
        if (!mounted) return;
        // That time has gone: back to the times, with it cleared.
        context.pushReplacement(
          RoutePaths.bookingAppointmentTime,
          extra: widget.selection.copyWith(clearSlot: true),
        );
      case 'PROFILE_REQUIRED':
        await promptCompleteProfile(context);
      default:
        await showErrorPopup(context, error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final selection = widget.selection;
    final doctor = selection.doctor!;
    final service = selection.service!;
    final slot = selection.slot!;
    final isHmo = selection.accessType == BookingAccessType.hmo;
    final uk = Formatters.ukTime(slot.startsAt);
    final inPerson = selection.mode == ConsultationMode.inPerson;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
                  MaxContentWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const AppHeaderBar(
                          showBack: true,
                          backFallback: RoutePaths.gp,
                        ),
                        const StepProgress(step: 6, total: 6),
                        const ScreenTitle(
                          title: 'Review your appointment',
                          subtitle: 'Check the details before you confirm.',
                        ),
                        const SizedBox(height: 10),
                        DetailList(
                          rows: [
                            ('Service', service.title),
                            ('Appointment', selection.mode.consultationLabel),
                            ('Clinician', doctor.name),
                            ('Date', Formatters.date(uk)),
                            (
                              'Time',
                              '${Formatters.time(uk)} · UK time '
                                  '(${Formatters.ukZoneLabel(slot.startsAt)})',
                            ),
                            if (inPerson && selection.city != null)
                              ('Location', selection.city!)
                            else if (!inPerson)
                              ('Location', 'Secure online appointment'),
                            ('Length', '${service.durationMinutes} min'),
                            if (selection.concern != null &&
                                selection.concern!.isNotEmpty)
                              ('Concern', selection.concern!),
                          ],
                        ),
                        PanelCard(
                          title: isHmo ? 'How it is paid for' : 'Payment',
                          child: Column(
                            children: [
                              DetailList(
                                rows: [
                                  (
                                    isHmo ? 'Funding' : 'Payment route',
                                    isHmo
                                        ? (selection.hmoName ?? 'Health plan')
                                        : 'Pay per visit',
                                  ),
                                  if (isHmo) ('Cover', _coverLabel(selection)),
                                ],
                              ),
                              if (!isHmo)
                                Container(
                                  padding: const EdgeInsets.only(top: 14),
                                  margin: const EdgeInsets.only(top: 4),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(color: palette.line),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Total',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: palette.ink,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        service.priceLabel,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: palette.ink,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        CheckRow(
                          value: _agreed,
                          onChanged: (value) => setState(() {
                            _agreed = value;
                            if (_agreed) _showAgreeError = false;
                          }),
                          label:
                              'I confirm that the information provided is '
                              'correct and I agree to the Terms of Service and '
                              'Privacy Policy.',
                        ),
                        if (_showAgreeError)
                          Padding(
                            padding: const EdgeInsets.only(left: 30),
                            child: Text(
                              'Please confirm to continue.',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: palette.danger,
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
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: MaxContentWidth(
                child: PrimaryButton(
                  label: 'Confirm booking',
                  loading: _loading,
                  onPressed: _confirm,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// What the plan said about covering the service, in a few words.
String _coverLabel(BookingSelection selection) {
  final check = selection.eligibility;
  if (check == null) return 'Cover checked on confirming';
  return switch (check.status) {
    EligibilityStatus.covered => 'Covered',
    EligibilityStatus.coPay =>
      check.coPayMinor == null
          ? 'Co-pay applies'
          : 'Co-pay ${Formatters.money(check.coPayMinor!)}',
    EligibilityStatus.preAuthorisationRequired => 'Needs authorisation',
    final other => other.label,
  };
}
