import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/inputs/app_text_field.dart';

/// Blueprint view 07 — Verify HMO Membership. No payer integration exists
/// yet, so "Verify my membership" always succeeds after a short delay
/// rather than checking a real HMO.
class VerifyHmoMembershipScreen extends StatefulWidget {
  const VerifyHmoMembershipScreen({super.key, required this.hmoName});

  final String hmoName;

  @override
  State<VerifyHmoMembershipScreen> createState() =>
      _VerifyHmoMembershipScreenState();
}

class _VerifyHmoMembershipScreenState extends State<VerifyHmoMembershipScreen> {
  final _memberIdController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _memberIdController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    super.dispose();
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
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'Verify your HMO membership',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const Text(
              'Enter your membership details to verify your cover with LifeCome Live.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.inkMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF7E8),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.health_and_safety_outlined,
                    color: AppColors.greenStrong,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      widget.hmoName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Change'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Membership ID',
              controller: _memberIdController,
              hintText: 'Enter your HMO membership ID',
              prefixIcon: Icons.badge_outlined,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Date of birth',
              controller: _dobController,
              hintText: 'DD/MM/YYYY',
              prefixIcon: Icons.calendar_today_outlined,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Phone number',
              controller: _phoneController,
              hintText: 'Enter your phone number',
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F4FC),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.blue),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      "We'll verify your membership in real time. Your details are securely "
                      'checked with your HMO to confirm your membership and eligible services.',
                      style: TextStyle(fontSize: 13, color: AppColors.ink),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Verify my membership',
              loading: _loading,
              onPressed: _verify,
            ),
          ],
        ),
      ),
    );
  }
}
