import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/feedback/app_popup.dart';

/// View/edit the patient's own profile. No profile-update backend exists
/// yet (the identity API has no `PATCH` for this), so "Save changes" just
/// confirms locally — see `IdentityService` for what's actually wired up.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    ref.read(sessionStoreProvider).read().then((session) {
      if (!mounted || session == null) return;
      setState(() {
        _nameController.text = session.displayName;
        _emailController.text = session.email;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
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
          'My profile',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.blue, AppColors.greenStrong],
                      ),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppColors.white,
                      size: 44,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Material(
                      color: AppColors.white,
                      shape: const CircleBorder(),
                      elevation: 2,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () async {
                          final source = await showUploadPhotoPopup(context);
                          // No image picker is wired up yet, so a chosen
                          // source ends at a coming-soon popup for now.
                          if (source == null || !context.mounted) return;
                          showComingSoonPopup(context, feature: 'Photo upload');
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            size: 18,
                            color: AppColors.blue,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField(
              label: 'Full name',
              controller: _nameController,
              hintText: 'Enter your full name',
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Email',
              controller: _emailController,
              hintText: 'Enter your email',
              keyboardType: TextInputType.emailAddress,
              enabled: false,
            ),
            const SizedBox(height: 4),
            const Text(
              'Your email is used to sign in and cannot be changed here.',
              style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Save changes',
              loading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
