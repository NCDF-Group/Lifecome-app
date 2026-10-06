import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_svg_icons.dart';
import '../../../core/widgets/design/soft_widgets.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/media/user_avatar.dart';
import '../application/avatar_controller.dart';
import '../domain/my_profile.dart';

/// View and edit the signed-in patient's own profile: name (saved to the backend), email (read-only,
/// it's the sign-in identity) and profile photo (uploaded to the backend).
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  PatientProfile? _profile;
  bool _loading = true;
  bool _saving = false;
  bool _photoBusy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final me = await ref.read(profileRepositoryProvider).getMe();
      if (!mounted) return;
      setState(() {
        _profile = me.profile;
        _emailController.text = me.email;
        _firstNameController.text = me.profile?.firstName ?? '';
        _lastNameController.text = me.profile?.lastName ?? '';
      });
    } on ApiException catch (error) {
      // Offline: still show the email we remember so the screen isn't empty.
      final session = await ref.read(sessionStoreProvider).read();
      if (!mounted) return;
      _emailController.text = session?.email ?? '';
      showErrorPopup(context, error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final profile = _profile;
    final first = _firstNameController.text.trim();
    final last = _lastNameController.text.trim();
    if (profile == null || first.isEmpty || last.isEmpty) {
      showErrorPopup(context, 'Enter your first and last name.');
      return;
    }
    setState(() => _saving = true);
    try {
      final saved = await ref
          .read(profileRepositoryProvider)
          .saveProfile(
            firstName: first,
            lastName: last,
            dateOfBirth: profile.dateOfBirth,
            country: profile.country,
          );
      await ref.read(sessionStoreProvider).saveDisplayName(saved.firstName);
      if (!mounted) return;
      setState(() => _profile = saved);
      showSuccessPopup(
        context,
        title: 'Profile updated',
        message: 'Your changes have been saved.',
      );
    } on ApiException catch (error) {
      if (mounted) showErrorPopup(context, error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _changePhoto() async {
    final source = await showUploadPhotoPopup(context);
    if (source == null || !mounted) return;
    setState(() => _photoBusy = true);
    try {
      await ref
          .read(avatarProvider.notifier)
          .pickAndUpload(
            source == PhotoSource.camera
                ? ImageSource.camera
                : ImageSource.gallery,
          );
    } on AvatarException catch (error) {
      if (mounted) showErrorPopup(context, error.message);
    } on ApiException catch (error) {
      if (mounted) showErrorPopup(context, error.message);
    } catch (_) {
      if (mounted) {
        showErrorPopup(
          context,
          'Could not open your photos. Check the app has permission and try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _photoBusy = false);
    }
  }

  Future<void> _removePhoto() async {
    setState(() => _photoBusy = true);
    try {
      await ref.read(avatarProvider.notifier).remove();
    } on ApiException catch (error) {
      if (mounted) showErrorPopup(context, error.message);
    } finally {
      if (mounted) setState(() => _photoBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = ref.watch(avatarProvider).value != null;

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
              child: Column(
                children: [
                  Stack(
                    children: [
                      const UserAvatar(size: 96),
                      if (_photoBusy)
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.white.withValues(alpha: 0.6),
                            ),
                            child: const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                ),
                              ),
                            ),
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
                            onTap: _photoBusy ? null : _changePhoto,
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
                  if (hasPhoto)
                    TextButton(
                      onPressed: _photoBusy ? null : _removePhoto,
                      child: const Text('Remove photo'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: 'First name',
              controller: _firstNameController,
              hintText: 'Enter your first name',
              enabled: !_loading,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Last name',
              controller: _lastNameController,
              hintText: 'Enter your last name',
              enabled: !_loading,
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
              onPressed: (_saving || _loading) ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
