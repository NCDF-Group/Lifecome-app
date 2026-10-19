import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/idempotency_key_generator.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/feedback/empty_state.dart';
import '../../../core/widgets/feedback/error_state.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/feedback/loading_indicator.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../booking/domain/models/booking_selection.dart';
import '../../profile/presentation/profile_required_prompt.dart';
import '../application/payer_controller.dart';
import '../domain/models/payer.dart';
import 'widgets/payer_errors.dart';

/// "Link your health plan" — check a membership with one of the plans taking
/// part, then see what it covers. The plans and the answer come from the
/// backend.
class LinkHealthPlanScreen extends ConsumerStatefulWidget {
  const LinkHealthPlanScreen({super.key, this.payer});

  /// A plan to start on, when the person has already chosen one.
  final Payer? payer;

  @override
  ConsumerState<LinkHealthPlanScreen> createState() =>
      _LinkHealthPlanScreenState();
}

class _LinkHealthPlanScreenState extends ConsumerState<LinkHealthPlanScreen> {
  final _policyController = TextEditingController();
  String? _payerId;
  String? _policyError;
  bool _submitted = false;
  bool _loading = false;

  String _key = newIdempotencyKey();
  String _keyFor = '';

  @override
  void initState() {
    super.initState();
    _payerId = widget.payer?.id;
  }

  @override
  void dispose() {
    _policyController.dispose();
    super.dispose();
  }

  Payer? _selected(List<Payer> payers) {
    if (payers.isEmpty) return null;
    for (final payer in payers) {
      if (payer.id == _payerId) return payer;
    }
    return payers.first;
  }

  bool _validate() {
    final error = Validators.memberId(_policyController.text);
    setState(() => _policyError = error);
    return error == null;
  }

  Future<void> _checkCover(Payer payer) async {
    if (_loading) return;
    setState(() => _submitted = true);
    if (!_validate()) return;

    final memberId = _policyController.text.trim();
    final fingerprint = '${payer.code}:$memberId';
    if (fingerprint != _keyFor) {
      _key = newIdempotencyKey();
      _keyFor = fingerprint;
    }

    setState(() => _loading = true);
    try {
      final plan = await ref
          .read(payerControllerProvider)
          .verify(payer: payer, memberId: memberId, idempotencyKey: _key);
      if (!mounted) return;
      context.push(RoutePaths.payerCoverage, extra: plan);
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.code == 'MEMBERSHIP_NOT_VERIFIED') {
        setState(
          () => _policyError = membershipErrorMessage(error, payer.name),
        );
      } else if (error.code == 'PROFILE_REQUIRED') {
        await promptCompleteProfile(context);
      } else {
        await showErrorPopup(context, error.message);
      }
    } catch (_) {
      if (mounted) {
        await showErrorPopup(
          context,
          'Something went wrong. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final payers = ref.watch(payersProvider);

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const AppHeaderBar(
              showBack: true,
              backFallback: RoutePaths.chooseAccess,
            ),
            const SizedBox(height: 4),
            const ScreenTitle(
              title: 'Link your health plan',
              subtitle:
                  'Check your cover for our services and access any '
                  'available benefits.',
            ),
            const SizedBox(height: AppSpacing.md),
            payers.when(
              loading: () => const LoadingIndicator(),
              error: (error, _) => ErrorState(
                error: error,
                onRetry: () => ref.invalidate(payersProvider),
              ),
              data: (all) {
                final payer = _selected(all);
                if (payer == null) {
                  return EmptyState(
                    icon: Icons.health_and_safety_outlined,
                    title: 'No health plans yet',
                    message:
                        'No plans are connected yet. You can still pay '
                        'directly for your consultation.',
                    actionLabel: 'Pay directly',
                    onAction: () => context.push(
                      RoutePaths.bookingChooseService,
                      extra: const BookingStart.direct(),
                    ),
                  );
                }
                return _form(context, all, payer);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            const InfoBanner(
              icon: Icons.lock_open_outlined,
              title: 'Your information stays private',
              message:
                  "We only check your cover. We don't share your records "
                  'with your insurer.',
            ),
            const SizedBox(height: AppSpacing.sm),
            Material(
              color: palette.tintBlue,
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.card),
                onTap: () => context.go(RoutePaths.messages),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: palette.elevated,
                        child: Icon(
                          Icons.help_outline,
                          size: 18,
                          color: palette.accent,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Can't find your plan?",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: palette.ink,
                              ),
                            ),
                            Text(
                              "Message the care team and we'll help you.",
                              style: TextStyle(
                                fontSize: 12.5,
                                color: palette.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: palette.accent),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _form(BuildContext context, List<Payer> all, Payer payer) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: palette.tintGreen,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plan provider',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: palette.ink,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: palette.elevated,
              borderRadius: BorderRadius.circular(AppRadius.control),
              border: Border.all(color: palette.line),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: payer.id,
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down, color: palette.inkMuted),
                items: [
                  for (final option in all)
                    DropdownMenuItem(
                      value: option.id,
                      child: Row(
                        children: [
                          Icon(
                            Icons.apartment_outlined,
                            size: 18,
                            color: palette.positive,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            option.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: palette.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
                onChanged: (value) => setState(() => _payerId = value),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Membership or policy number',
            controller: _policyController,
            hintText: 'Enter your membership or policy number',
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.characters,
            errorText: _policyError,
            onChanged: (_) {
              if (_submitted) _validate();
            },
            onSubmitted: (_) => _checkCover(payer),
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            label: 'Check my cover',
            icon: Icons.chevron_right,
            loading: _loading,
            onPressed: () => _checkCover(payer),
          ),
        ],
      ),
    );
  }
}
