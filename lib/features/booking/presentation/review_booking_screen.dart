import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../domain/models/appointment.dart';

/// Blueprint views 15-16 — Review Booking & Payment, then Payment / HMO
/// Authorisation. The design merges both into one screen (see the
/// screenshots): the review shows what will happen, and confirming it is
/// itself the payment/authorisation step — there's no separate payment
/// processor wired in, so paying always "succeeds" after a short delay.
class ReviewBookingScreen extends StatefulWidget {
  const ReviewBookingScreen({super.key, required this.selection});

  final BookingSelection selection;

  @override
  State<ReviewBookingScreen> createState() => _ReviewBookingScreenState();
}

class _ReviewBookingScreenState extends State<ReviewBookingScreen> {
  bool _agreed = true;
  bool _loading = false;

  Future<void> _confirm() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    context.push(RoutePaths.bookingConfirmation, extra: widget.selection);
  }

  @override
  Widget build(BuildContext context) {
    final selection = widget.selection;
    final doctor = selection.doctor!;
    final service = selection.service!;
    final covered = selection.isCovered;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'Review and confirm',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  const Text(
                    'Please check your appointment details before confirming.',
                    style: TextStyle(fontSize: 14, color: AppColors.inkMuted),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.line),
                      borderRadius: BorderRadius.circular(AppRadius.card),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.blue.withValues(
                            alpha: 0.1,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: AppColors.blue,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctor.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink,
                                ),
                              ),
                              Text(
                                doctor.specialty,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.inkMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${selection.date!.day}/${selection.date!.month}/${selection.date!.year}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                            Text(
                              selection.time ?? '',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.inkMuted,
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
                    trailing: covered
                        ? 'Covered by ${selection.hmoName}'
                        : (selection.accessType == BookingAccessType.hmo
                              ? 'Requires authorisation'
                              : null),
                    trailingColor: covered
                        ? AppColors.greenStrong
                        : AppColors.gold,
                  ),
                  _ReviewRow(
                    icon: Icons.credit_card,
                    label: 'Payment method',
                    value: covered
                        ? (selection.hmoName ?? 'HMO')
                        : 'Card or bank transfer',
                    trailing: covered
                        ? 'No payment required'
                        : '₦${service.fee}',
                    trailingColor: covered
                        ? AppColors.greenStrong
                        : AppColors.ink,
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
                    onChanged: (value) =>
                        setState(() => _agreed = value ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'I confirm that the information provided is correct and I agree to the '
                      'Terms of Service and Privacy Policy.',
                      style: TextStyle(fontSize: 13, color: AppColors.ink),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: PrimaryButton(
                label: covered ? 'Confirm appointment' : 'Pay and confirm',
                icon: Icons.arrow_forward,
                loading: _loading,
                onPressed: _agreed ? _confirm : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
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
          Icon(icon, size: 20, color: AppColors.inkMuted),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.inkMuted,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null)
            Text(
              trailing!,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: trailingColor ?? AppColors.ink,
              ),
            ),
        ],
      ),
    );
  }
}
