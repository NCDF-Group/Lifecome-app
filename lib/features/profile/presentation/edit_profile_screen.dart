import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/inputs/app_text_field.dart';

const _communicationOptions = [
  'No specific needs',
  'British Sign Language (BSL) interpreter',
  'Easy read documents',
  'Other support needed',
];

/// "Your care profile" — the demographic and contact details used to
/// coordinate care, distinct from account settings (email/password, handled
/// elsewhere). No profile-update backend exists yet (the identity API has
/// no `PATCH` for this, and `patients` has no address/GP-practice/
/// communication-needs columns), so "Save profile" just confirms locally —
/// see `IdentityService` for what's actually wired up.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _postcodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _gpPracticeController = TextEditingController();

  String? _communicationNeed;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    ref.read(sessionStoreProvider).read().then((session) {
      if (!mounted || session == null) return;
      final parts = session.displayName.trim().split(' ');
      setState(() {
        _firstNameController.text = parts.first;
        if (parts.length > 1) {
          _lastNameController.text = parts.skip(1).join(' ');
        }
      });
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _postcodeController.dispose();
    _cityController.dispose();
    _gpPracticeController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25),
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

  Future<void> _pickCommunicationNeed() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in _communicationOptions)
              ListTile(
                title: Text(option),
                trailing: option == _communicationNeed
                    ? const Icon(Icons.check, color: AppColors.blue)
                    : null,
                onTap: () => Navigator.of(context).pop(option),
              ),
          ],
        ),
      ),
    );
    if (selected != null) setState(() => _communicationNeed = selected);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _saving = false);
    showSuccessPopup(
      context,
      title: 'Profile updated',
      message: 'Your changes have been saved.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'Your care profile',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const Text(
              'Keep your details up to date so we can provide the best care for you.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.inkMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _SectionCard(
              background: const Color(0xFFEAF7E8),
              icon: Icons.person_outline,
              iconColor: AppColors.greenStrong,
              title: 'Personal details',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'First name',
                        controller: _firstNameController,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppTextField(
                        label: 'Last name',
                        controller: _lastNameController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Date of birth',
                  controller: _dobController,
                  hintText: 'DD / MM / YYYY',
                  readOnly: true,
                  onTap: _pickDateOfBirth,
                  suffixIcon: const Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _SectionCard(
              background: const Color(0xFFE3EEFB),
              icon: Icons.home_outlined,
              iconColor: AppColors.blue,
              title: 'Home address',
              children: [
                AppTextField(
                  label: 'Address line 1',
                  controller: _addressLine1Controller,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Address line 2 (optional)',
                  controller: _addressLine2Controller,
                  hintText: 'e.g. Flat 2, Riverside House',
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Postcode',
                        controller: _postcodeController,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppTextField(
                        label: 'City or town',
                        controller: _cityController,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _SectionCard(
              background: const Color(0xFFEAF7E8),
              icon: Icons.local_hospital_outlined,
              iconColor: AppColors.greenStrong,
              title: 'NHS GP practice (optional)',
              children: [
                const Text(
                  'Helps us coordinate your care with your GP.',
                  style: TextStyle(fontSize: 12.5, color: AppColors.inkMuted),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _gpPracticeController,
                  style: const TextStyle(fontSize: 16, color: AppColors.ink),
                  decoration: const InputDecoration(
                    hintText: 'Search for your GP practice',
                    prefixIcon: Icon(
                      Icons.search,
                      size: 20,
                      color: AppColors.inkMuted,
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _SectionCard(
              background: AppColors.surface,
              icon: Icons.chat_bubble_outline,
              iconColor: AppColors.blue,
              title: 'Communication needs',
              children: [
                const Text(
                  'Let us know if you need support with communication.',
                  style: TextStyle(fontSize: 12.5, color: AppColors.inkMuted),
                ),
                const SizedBox(height: AppSpacing.sm),
                Material(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppRadius.control),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.control),
                    onTap: _pickCommunicationNeed,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.control),
                        border: Border.all(color: AppColors.line, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _communicationNeed ?? 'Select an option',
                              style: TextStyle(
                                fontSize: 16,
                                color: _communicationNeed != null
                                    ? AppColors.ink
                                    : AppColors.inkMuted,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.inkMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.card),
                onTap: () =>
                    showComingSoonPopup(context, feature: 'Medical history'),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Medical history',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                            Text(
                              'Add details about your medical conditions, allergies and medications.',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: AppColors.inkMuted,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.inkMuted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE3EEFB),
                borderRadius: BorderRadius.circular(AppRadius.control),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, size: 18, color: AppColors.blue),
                  SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'Your payer cannot see your clinical records.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Save profile',
              loading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.background,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.children,
  });

  final Color background;
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }
}
