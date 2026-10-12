import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/layout/app_header_bar.dart';

enum _AccessTab { membership, employer }

/// "Activate your access" — enter an invitation or membership code to
/// link funding to the account. No eligibility backend exists yet, so
/// "Check invitation"/"Check membership" always succeeds after a short
/// delay.
class ActivateAccessScreen extends StatefulWidget {
  const ActivateAccessScreen({super.key});

  @override
  State<ActivateAccessScreen> createState() => _ActivateAccessScreenState();
}

class _ActivateAccessScreenState extends State<ActivateAccessScreen> {
  _AccessTab _tab = _AccessTab.employer;
  final _codeController = TextEditingController();
  final _emailController = TextEditingController();
  bool _loading = false;

  bool get _isEmployer => _tab == _AccessTab.employer;

  @override
  void dispose() {
    _codeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _loading = false);
    if (_isEmployer) {
      context.push(RoutePaths.payerCoverage, extra: 'Your employer scheme');
    } else {
      context.push(RoutePaths.myBenefits);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            AppHeaderBar(showBack: true, onBack: () => context.pop()),
            const SizedBox(height: 20),
            const Text(
              'Activate your access',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'An invitation links funding to your private account.',
              style: TextStyle(fontSize: 14, color: AppColors.inkMuted),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _TabButton(
                      label: 'Membership',
                      selected: !_isEmployer,
                      onTap: () => setState(() => _tab = _AccessTab.membership),
                    ),
                  ),
                  Expanded(
                    child: _TabButton(
                      label: 'Employer or sponsor',
                      selected: _isEmployer,
                      onTap: () => setState(() => _tab = _AccessTab.employer),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: _isEmployer
                    ? const Color(0xFFEAF7E8)
                    : const Color(0xFFE3EEFB),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.white,
                    child: Icon(
                      _isEmployer
                          ? Icons.apartment_outlined
                          : Icons.badge_outlined,
                      color: _isEmployer
                          ? AppColors.greenStrong
                          : AppColors.blue,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEmployer
                              ? 'Employer or sponsor access'
                              : 'Personal membership access',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          _isEmployer
                              ? 'Use your invitation code from your '
                                    'employer or scheme administrator.'
                              : 'Use your membership code to activate '
                                    'your account.',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.inkMuted,
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
            AppTextField(
              label: _isEmployer ? 'Invitation code' : 'Membership code',
              controller: _codeController,
              hintText: _isEmployer
                  ? 'Enter invitation code'
                  : 'Enter membership code',
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Personal email',
              controller: _emailController,
              hintText: 'name@example.com',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AppSpacing.md),
            Material(
              color: AppColors.blue,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                onTap: _loading ? null : _check,
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  child: _loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: AppColors.white,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _isEmployer
                                  ? 'Check invitation'
                                  : 'Check membership',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward,
                              color: AppColors.white,
                              size: 20,
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFFE3EEFB),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.white,
                    child: Icon(
                      Icons.help_outline,
                      size: 18,
                      color: AppColors.blue,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEmployer ? 'No invitation?' : 'No code?',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          _isEmployer
                              ? 'Contact your scheme administrator.'
                              : 'Contact patient support.',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Choose another access route',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Material(
              color: const Color(0xFFEAF7E8),
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.card),
                onTap: _isEmployer
                    ? () => context.push(RoutePaths.membershipPlans)
                    : () => setState(() => _tab = _AccessTab.employer),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.white,
                        child: Icon(
                          Icons.person_outline,
                          size: 18,
                          color: AppColors.greenStrong,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isEmployer
                                  ? 'Use a personal membership'
                                  : 'Use employer or sponsor access',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                            Text(
                              _isEmployer
                                  ? "If you're paying for your own care."
                                  : 'If your employer or scheme covers you.',
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.greenStrong,
                      ),
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
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.blue : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onTap,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.white : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
