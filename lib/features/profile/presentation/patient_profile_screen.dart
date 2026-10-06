import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/animation/fade_in.dart';
import '../../../core/country/app_country.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/services/session_store.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_svg_icons.dart';
import '../../../core/widgets/design/soft_widgets.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/media/user_avatar.dart';
import '../../auth/application/auth_controller.dart';
import '../../notifications/application/notifications_controller.dart';
import '../application/avatar_controller.dart';
import '../../dashboard/presentation/widgets/home_header.dart';

/// The Profile tab: the account summary card, then the account, support and
/// legal links as the same soft rows used across Home, Book and Records, and
/// sign out / delete account at the bottom.
class PatientProfileScreen extends ConsumerStatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  ConsumerState<PatientProfileScreen> createState() =>
      _PatientProfileScreenState();
}

class _PatientProfileScreenState extends ConsumerState<PatientProfileScreen> {
  StoredSession? _session;

  @override
  void initState() {
    super.initState();
    ref.read(sessionStoreProvider).read().then((session) {
      if (mounted) setState(() => _session = session);
    });
  }

  Future<void> _signOut() async {
    await ref.read(sessionStoreProvider).clear();
    ref.read(apiClientProvider).accessToken = null;
    ref.invalidate(avatarProvider);
    ref.invalidate(notificationsProvider);
    ref.read(authControllerProvider.notifier).reset();
    if (mounted) context.go(RoutePaths.welcome);
  }

  Future<void> _pickCountry() async {
    final picked = await showCountryPickerPopup(
      context,
      current: ref.read(countryProvider),
    );
    if (picked != null) {
      await ref.read(countryProvider.notifier).select(picked);
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showConfirmPopup(
      context,
      title: 'Delete your account?',
      message:
          'This permanently removes your profile, visit history and care plan. '
          'This cannot be undone.',
      confirmLabel: 'Delete account',
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    showAppPopup<void>(
      context,
      kind: AppPopupKind.info,
      title: 'Contact patient support',
      message:
          "Account deletion isn't available in the app yet. Contact patient "
          'support and they will delete your account for you.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = _session?.displayName ?? 'Your account';
    final email = _session?.email ?? '';
    final country = ref.watch(countryProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: [
            const HomeHeader(),
            const SizedBox(height: 28),
            const FadeIn(
              child: PageHeading(
                'Your profile',
                subtitle: 'Manage your account and preferences.',
              ),
            ),
            const SizedBox(height: 22),
            FadeIn(
              delay: const Duration(milliseconds: 60),
              child: _AccountCard(
                name: name,
                email: email,
                onView: () => context.push(RoutePaths.editProfile),
              ),
            ),
            const _SectionLabel('Account'),
            ActionRow(
              glyph: AppSvgGlyph.userBold,
              title: 'My profile',
              onTap: () => context.push(RoutePaths.editProfile),
            ),
            const SizedBox(height: 12),
            ActionRow(
              glyph: AppSvgGlyph.documentBold,
              title: 'Health records',
              onTap: () => context.go(RoutePaths.healthRecords),
            ),
            const SizedBox(height: 12),
            ActionRow(
              glyph: AppSvgGlyph.pinBold,
              title: 'Country',
              trailingText: country.name,
              onTap: _pickCountry,
            ),
            const _SectionLabel('Support'),
            ActionRow(
              glyph: AppSvgGlyph.chatBold,
              title: 'Help and support',
              onTap: () => context.push(RoutePaths.helpAndSupport),
            ),
            const _SectionLabel('Legal'),
            ActionRow(
              glyph: AppSvgGlyph.hexagonBold,
              title: 'Privacy Policy',
              onTap: () => context.push(RoutePaths.privacyPolicy),
            ),
            const SizedBox(height: 12),
            ActionRow(
              glyph: AppSvgGlyph.documentBold,
              title: 'Terms and Conditions',
              onTap: () => context.push(RoutePaths.termsAndConditions),
            ),
            const SizedBox(height: 28),
            LinkRow(
              glyph: AppSvgGlyph.logoutLine,
              title: 'Sign out',
              onTap: _signOut,
            ),
            LinkRow(
              glyph: AppSvgGlyph.trashBold,
              color: AppColors.alertRed,
              textColor: AppColors.alertRed,
              title: 'Delete my account',
              onTap: _confirmDeleteAccount,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          color: Color(0xFF0B101A),
        ),
      ),
    );
  }
}

/// Avatar, name and email on a soft card, with a "View profile" pill.
class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.name,
    required this.email,
    required this.onView,
  });

  final String name;
  final String email;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const UserAvatar(size: 56),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          letterSpacing: -0.3,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PillButton(label: 'View profile', onPressed: onView),
        ],
      ),
    );
  }
}
