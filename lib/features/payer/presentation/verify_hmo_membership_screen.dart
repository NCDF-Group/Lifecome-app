import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/layout/app_header_bar.dart';

/// Blueprint view 07 — Verify Your Eligibility (employer/sponsor access).
/// No payer integration exists yet, so "Verify eligibility" always
/// succeeds after a short delay rather than checking a real employer or
/// HMO record.
class VerifyHmoMembershipScreen extends StatefulWidget {
  const VerifyHmoMembershipScreen({super.key, required this.hmoName});

  final String hmoName;

  @override
  State<VerifyHmoMembershipScreen> createState() =>
      _VerifyHmoMembershipScreenState();
}

class _VerifyHmoMembershipScreenState extends State<VerifyHmoMembershipScreen> {
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _emailController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 30),
      firstDate: DateTime(now.year - 120),
      lastDate: now,
      helpText: 'Date of birth',
    );
    if (picked == null) return;
    setState(() {
      _dobController.text =
          '${picked.day.toString().padLeft(2, '0')} / '
          '${picked.month.toString().padLeft(2, '0')} / ${picked.year}';
    });
  }

  Future<void> _verify() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _loading = false);
    context.push(RoutePaths.payerCoverage, extra: widget.hmoName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            AppHeaderBar(showBack: true, onBack: () => context.pop()),
            const SizedBox(height: 20),
            Text(
              'Verify your eligibility',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: context.palette.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'We’ve recognised your invitation. Please check your '
              'details so we can verify your access.',
              style: TextStyle(
                fontSize: 14,
                color: context.palette.inkMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.palette.tintGreen,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: context.palette.elevated,
                    child: Icon(
                      Icons.apartment_outlined,
                      color: context.palette.positive,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Invitation recognised',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: context.palette.positive,
                          ),
                        ),
                        Text(
                          'Employer or sponsor access',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: context.palette.ink,
                          ),
                        ),
                        Text(
                          'Your organisation provides access to LifeCome '
                          'Live.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: context.palette.inkMuted,
                            height: 1.4,
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
                border: Border.all(color: context.palette.line),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Column(
                children: [
                  AppTextField(
                    label: 'Full name',
                    controller: _nameController,
                    hintText: 'Enter your full name',
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'Date of birth',
                    controller: _dobController,
                    hintText: 'DD / MM / YYYY',
                    readOnly: true,
                    onTap: _pickDateOfBirth,
                    suffixIcon: Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: context.palette.inkMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'Personal email',
                    controller: _emailController,
                    hintText: 'Enter your email address',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.email],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: 'Verify eligibility',
              icon: Icons.arrow_forward,
              loading: _loading,
              onPressed: _verify,
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: context.palette.surface,
                borderRadius: BorderRadius.circular(AppRadius.control),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: context.palette.accent,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'This checks your funding, not your clinical '
                      'suitability.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: context.palette.inkMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'If your details do not match',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.palette.ink,
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
                      background: context.palette.tintGreen,
                      iconColor: context.palette.positive,
                      title: 'Get help',
                      subtitle: 'Speak to our team.',
                      onTap: () => context.go(RoutePaths.messages),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _FallbackCard(
                      icon: Icons.sync_alt,
                      background: context.palette.tintBlue,
                      iconColor: context.palette.accent,
                      title: 'Choose another way',
                      subtitle: 'Other ways to access.',
                      onTap: () => context.pop(),
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
