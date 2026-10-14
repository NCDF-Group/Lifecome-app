import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/idempotency_key_generator.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/router/safe_back.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../application/payer_controller.dart';
import '../../profile/presentation/profile_required_prompt.dart';
import '../domain/models/payer.dart';
import 'widgets/payer_errors.dart';

/// Blueprint view 07 — Verify Your Membership. The membership number is
/// checked with the health plan itself; the plan's own answer decides.
class VerifyHmoMembershipScreen extends ConsumerStatefulWidget {
  const VerifyHmoMembershipScreen({super.key, required this.payer});

  final Payer payer;

  @override
  ConsumerState<VerifyHmoMembershipScreen> createState() =>
      _VerifyHmoMembershipScreenState();
}

class _VerifyHmoMembershipScreenState
    extends ConsumerState<VerifyHmoMembershipScreen> {
  final _memberController = TextEditingController();
  String? _memberError;
  bool _submitted = false;
  bool _loading = false;

  /// A retry of the same number reuses its key, so it can never add a second
  /// membership; a different number gets a new one.
  String _key = newIdempotencyKey();
  String _keyFor = '';

  @override
  void dispose() {
    _memberController.dispose();
    super.dispose();
  }

  bool _validate() {
    final error = Validators.memberId(_memberController.text);
    setState(() => _memberError = error);
    return error == null;
  }

  Future<void> _verify() async {
    if (_loading) return;
    setState(() => _submitted = true);
    if (!_validate()) return;

    final memberId = _memberController.text.trim();
    if (memberId != _keyFor) {
      _key = newIdempotencyKey();
      _keyFor = memberId;
    }

    setState(() => _loading = true);
    try {
      final plan = await ref
          .read(payerControllerProvider)
          .verify(
            payer: widget.payer,
            memberId: memberId,
            idempotencyKey: _key,
          );
      if (!mounted) return;
      context.push(RoutePaths.payerCoverage, extra: plan);
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.code == 'MEMBERSHIP_NOT_VERIFIED') {
        setState(
          () => _memberError = membershipErrorMessage(error, widget.payer.name),
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
    final payer = widget.payer;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const AppHeaderBar(showBack: true),
            const SizedBox(height: 20),
            const ScreenTitle(
              title: 'Verify your membership',
              subtitle:
                  'Enter the membership number from your card so we can '
                  'check it with your plan.',
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: palette.tintGreen,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: palette.elevated,
                    child: Icon(
                      Icons.health_and_safety_outlined,
                      color: palette.positive,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your health plan',
                          style: TextStyle(
                            fontSize: 13,
                            color: palette.inkMuted,
                          ),
                        ),
                        Text(
                          payer.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: palette.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                border: Border.all(color: palette.line),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: AppTextField(
                label: 'Membership number',
                controller: _memberController,
                hintText: 'Enter your membership number',
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.characters,
                errorText: _memberError,
                onChanged: (_) {
                  if (_submitted) _validate();
                },
                onSubmitted: (_) => _verify(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: 'Verify membership',
              icon: Icons.arrow_forward,
              loading: _loading,
              onPressed: _verify,
            ),
            const SizedBox(height: AppSpacing.sm),
            const InfoBanner(
              message:
                  'This checks your funding, not your clinical suitability.',
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'If your details do not match',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: palette.ink,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _FallbackCard(
                      icon: Icons.headset_mic_outlined,
                      background: palette.tintGreen,
                      iconColor: palette.positive,
                      title: 'Get help',
                      subtitle: 'Speak to our team.',
                      onTap: () => context.go(RoutePaths.messages),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _FallbackCard(
                      icon: Icons.sync_alt,
                      background: palette.tintBlue,
                      iconColor: palette.accent,
                      title: 'Choose another way',
                      subtitle: 'Other ways to access.',
                      onTap: () =>
                          context.goBack(fallback: RoutePaths.chooseAccess),
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

class _FallbackCard extends StatelessWidget {
  const _FallbackCard({
    required this.icon,
    required this.background,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: iconColor, size: 20),
                  const Spacer(),
                  Icon(Icons.chevron_right, color: iconColor, size: 18),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: context.palette.ink,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: context.palette.inkMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
