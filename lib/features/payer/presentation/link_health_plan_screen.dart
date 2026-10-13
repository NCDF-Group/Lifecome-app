import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/layout/app_header_bar.dart';

const _providers = [
  'LifeCome Benefits',
  'LifeCome HMO',
  'Bupa',
  'AXA Health',
  'Vitality',
  'Aviva',
  'WPA',
];

/// "Link your health plan" — confirm cover with LifeCome Benefits or a
/// participating HMO before booking. No eligibility backend exists yet,
/// so "Check my cover" always succeeds after a short delay.
class LinkHealthPlanScreen extends StatefulWidget {
  const LinkHealthPlanScreen({super.key, this.provider});

  final String? provider;

  @override
  State<LinkHealthPlanScreen> createState() => _LinkHealthPlanScreenState();
}

class _LinkHealthPlanScreenState extends State<LinkHealthPlanScreen> {
  late String _provider = widget.provider ?? _providers.first;
  final _policyController = TextEditingController();
  final _dobController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _policyController.dispose();
    _dobController.dispose();
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

  Future<void> _checkCover() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _loading = false);
    context.push(RoutePaths.payerCoverage, extra: _provider);
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
              'Link your health plan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: context.palette.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Check your cover for our services and access any available '
              'benefits.',
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Plan provider',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: context.palette.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: context.palette.elevated,
                      borderRadius: BorderRadius.circular(AppRadius.control),
                      border: Border.all(color: context.palette.line),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _provider,
                        isExpanded: true,
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: context.palette.inkMuted,
                        ),
                        items: [
                          for (final provider in _providers)
                            DropdownMenuItem(
                              value: provider,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.apartment_outlined,
                                    size: 18,
                                    color: context.palette.positive,
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    provider,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: context.palette.ink,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                        onChanged: (value) =>
                            setState(() => _provider = value ?? _provider),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'Membership or policy number',
                    controller: _policyController,
                    hintText: 'Enter your membership or policy number',
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
                  Material(
                    color: AppColors.blue,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      onTap: _loading ? null : _checkCover,
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
                            : const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Check my cover',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.white,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.chevron_right,
                                    color: AppColors.white,
                                    size: 20,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.palette.tintBlue,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: context.palette.elevated,
                    child: Icon(
                      Icons.lock_open_outlined,
                      size: 18,
                      color: context.palette.accent,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your information stays private',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: context.palette.ink,
                          ),
                        ),
                        Text(
                          "We only check your cover. We don't share your "
                          'records with your insurer.',
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
            const SizedBox(height: AppSpacing.lg),
            Text(
              "What's covered?",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: context.palette.ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "We'll check your cover for these services.",
              style: TextStyle(fontSize: 13, color: context.palette.inkMuted),
            ),
            const SizedBox(height: AppSpacing.sm),
            _CoverageRow(
              background: context.palette.tintGreen,
              icon: Icons.desktop_windows_outlined,
              iconColor: context.palette.positive,
              title: 'Online GP',
              subtitle: 'Video or phone appointments',
            ),
            const SizedBox(height: AppSpacing.sm),
            _CoverageRow(
              background: context.palette.tintBlue,
              icon: Icons.apartment_outlined,
              iconColor: context.palette.accent,
              title: 'Smart GP clinics',
              subtitle: 'Care in person',
            ),
            const SizedBox(height: AppSpacing.sm),
            _CoverageRow(
              background: context.palette.tintGreen,
              icon: Icons.description_outlined,
              iconColor: context.palette.positive,
              title: 'Health records',
              subtitle: 'Access your records and care plans',
            ),
            const SizedBox(height: AppSpacing.sm),
            Material(
              color: context.palette.tintBlue,
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.card),
                onTap: () => showComingSoonPopup(
                  context,
                  feature: 'Contacting patient support',
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: context.palette.elevated,
                        child: Icon(
                          Icons.help_outline,
                          size: 18,
                          color: context.palette.accent,
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
                                color: context.palette.ink,
                              ),
                            ),
                            Text(
                              "Contact support and we'll help you.",
                              style: TextStyle(
                                fontSize: 12.5,
                                color: context.palette.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: context.palette.accent),
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

class _CoverageRow extends StatelessWidget {
  const _CoverageRow({
    required this.background,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final Color background;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: context.palette.elevated,
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: context.palette.ink,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: context.palette.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: context.palette.positive),
        ],
      ),
    );
  }
}
