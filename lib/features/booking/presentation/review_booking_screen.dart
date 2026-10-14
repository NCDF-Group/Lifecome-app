import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/idempotency_key_generator.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/layout/back_app_bar.dart';
import '../../../core/widgets/layout/max_content_width.dart';
import '../../../core/widgets/media/avatar.dart';
import '../../payer/domain/models/eligibility_status.dart';
import '../application/booking_controller.dart';
import '../../profile/presentation/profile_required_prompt.dart';
import '../domain/models/booking_selection.dart';
import '../domain/models/consultation_mode.dart';

/// Blueprint views 15-16 — Review Booking & Payment, then Payment / HMO
/// Authorisation, merged into one screen: the review shows what will be
/// booked, and confirming it creates the appointment on the backend.
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
    final selection = widget.selection;
    final doctor = selection.doctor!;
    final service = selection.service!;
    final slot = selection.slot!;
    final isHmo = selection.accessType == BookingAccessType.hmo;
    final uk = Formatters.ukTime(slot.startsAt);

    return Scaffold(
      backgroundColor: context.palette.background,
      appBar: const BackAppBar(title: 'Review and confirm'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  MaxContentWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Please check your appointment details before '
                          'confirming.',
                          style: TextStyle(
                            fontSize: 14,
                            color: context.palette.inkMuted,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            border: Border.all(color: context.palette.line),
                            borderRadius: BorderRadius.circular(AppRadius.card),
                          ),
                          child: Row(
                            children: [
                              UserAvatar(name: doctor.name, radius: 22),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doctor.name,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: context.palette.ink,
                                      ),
                                    ),
                                    Text(
                                      doctor.specialty,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: context.palette.inkMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    Formatters.date(uk),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: context.palette.ink,
                                    ),
                                  ),
                                  Text(
                                    '${Formatters.time(uk)} '
                                    '${Formatters.ukZoneLabel(slot.startsAt)}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: context.palette.inkMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _ReviewRow(
                          icon: Icons.description_outlined,
                          label: 'Service',
                          value: service.title,
                          trailing: '${service.durationMinutes} min',
                        ),
                        _ReviewRow(
                          icon: selection.mode == ConsultationMode.inPerson
                              ? Icons.apartment_outlined
                              : (selection.mode == ConsultationMode.audio
                                    ? Icons.call_outlined
                                    : Icons.videocam_outlined),
                          label: 'Appointment type',
                          value: selection.mode.consultationLabel,
                          trailing: selection.mode == ConsultationMode.inPerson
                              ? selection.city
                              : null,
                        ),
                        _ReviewRow(
                          icon: Icons.credit_card,
                          label: isHmo ? 'Funding' : 'Payment',
                          value: isHmo
                              ? (selection.hmoName ?? 'Health plan')
                              : 'Pay per visit',
                          trailing: isHmo
                              ? _coverLabel(selection)
                              : service.priceLabel,
                          trailingColor: isHmo
                              ? _coverColor(context, selection)
                              : context.palette.ink,
                        ),
                        if (selection.concern != null &&
                            selection.concern!.isNotEmpty)
                          _ReviewRow(
                            icon: Icons.notes_outlined,
                            label: 'Concern',
                            value: selection.concern!,
                          ),
                        const SizedBox(height: AppSpacing.md),
                        CheckboxListTile(
                          value: _agreed,
                          onChanged: (value) => setState(() {
                            _agreed = value ?? false;
                            if (_agreed) _showAgreeError = false;
                          }),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'I confirm that the information provided is '
                            'correct and I agree to the Terms of Service and '
                            'Privacy Policy.',
                            style: TextStyle(
                              fontSize: 13,
                              color: context.palette.ink,
                            ),
                          ),
                        ),
                        if (_showAgreeError)
                          Text(
                            'Please confirm to continue.',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.palette.danger,
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
              child: MaxContentWidth(
                child: PrimaryButton(
                  label: 'Confirm booking',
                  icon: Icons.arrow_forward,
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

Color _coverColor(BuildContext context, BookingSelection selection) {
  final status = selection.eligibility?.status;
  return status == EligibilityStatus.covered
      ? context.palette.positive
      : context.palette.warning;
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
    this.trailingColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? trailing;
  final Color? trailingColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: context.palette.inkMuted),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.palette.inkMuted,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: context.palette.ink,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.xs),
            Text(
              trailing!,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: trailingColor ?? context.palette.ink,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
