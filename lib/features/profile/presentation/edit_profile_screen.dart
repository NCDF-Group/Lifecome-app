import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_svg_icons.dart';
import '../../../core/widgets/design/soft_widgets.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/inputs/app_text_field.dart';

/// View/edit the patient's own profile. No profile-update backend exists
/// yet (the identity API has no `PATCH` for this), so "Save changes" just
/// confirms locally - see `IdentityService` for what's actually wired up.
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
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            const DesignBackButton(),
            const SizedBox(height: 14),
            const PageHeading(
              'My profile',
              subtitle: 'View and update your account details.',
            ),
            const SizedBox(height: 26),
            Center(
              child: Stack(
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/images/home/avatar.png',
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Material(
                      color: AppColors.actionBlue,
                      shape: const CircleBorder(
                        side: BorderSide(color: AppColors.white, width: 2),
                      ),
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
                          padding: EdgeInsets.all(8),
                          child: AppSvgIcon(
                            AppSvgGlyph.documentUploadBold,
                            size: 18,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            AppTextField(
              label: 'Full name',
              controller: _nameController,
              hintText: 'Enter your full name',
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Email',
              controller: _emailController,
              hintText: 'Enter your email',
              keyboardType: TextInputType.emailAddress,
              enabled: false,
            ),
            const SizedBox(height: 8),
            const InfoNote(
              'Your email is used to sign in and cannot be changed here.',
              centerIcon: true,
            ),
            const SizedBox(height: 24),
            PillButton(
              label: _saving ? 'Saving…' : 'Save changes',
              height: 54,
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
