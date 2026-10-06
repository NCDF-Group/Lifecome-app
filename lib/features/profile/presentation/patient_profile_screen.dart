import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/services/session_store.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/application/auth_controller.dart';
import '../../../core/widgets/feedback/app_popup.dart';

/// The Profile tab landing screen — account summary plus links into health
/// records, support, legal pages and account management.
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
    ref.read(authControllerProvider.notifier).reset();
    if (mounted) context.go(RoutePaths.welcome);
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

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(AppRadius.card),
              onTap: () => context.push(RoutePaths.editProfile),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFE8F4FC), Color(0xFFEAF7E8)],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
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
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                          if (email.isNotEmpty)
                            Text(
                              email,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.inkMuted,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.inkMuted),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _SectionCard(
              label: 'Account',
              tiles: [
                _MenuTile(
                  icon: Icons.person_outline_rounded,
                  label: 'My profile',
                  onTap: () => context.push(RoutePaths.editProfile),
                ),
                _MenuTile(
                  icon: Icons.folder_shared_outlined,
                  label: 'Health records',
                  onTap: () => context.push(RoutePaths.healthRecords),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _SectionCard(
              label: 'Support',
              tiles: [
                _MenuTile(
                  icon: Icons.help_outline_rounded,
                  label: 'Help and support',
                  onTap: () => context.push(RoutePaths.helpAndSupport),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _SectionCard(
              label: 'Legal',
              tiles: [
                _MenuTile(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy Policy',
                  onTap: () => context.push(RoutePaths.privacyPolicy),
                ),
                _MenuTile(
                  icon: Icons.description_outlined,
                  label: 'Terms and Conditions',
                  onTap: () => context.push(RoutePaths.termsAndConditions),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _SectionCard(
              label: 'Danger zone',
              tiles: [
                _MenuTile(
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete my account',
                  color: AppColors.error,
                  onTap: _confirmDeleteAccount,
                ),
                _MenuTile(
                  icon: Icons.logout_rounded,
                  label: 'Sign out',
                  color: AppColors.error,
                  onTap: _signOut,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A titled group of menu rows on a soft tonal background — replaces plain
/// flat list rows with a "card per section" feel.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.label, required this.tiles});

  final String label;
  final List<_MenuTile> tiles;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            bottom: AppSpacing.xs,
            left: AppSpacing.xxs,
          ),
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.inkMuted,
              letterSpacing: 0.6,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE8F4FC),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Column(
            children: [
              for (var i = 0; i < tiles.length; i++) ...[
                tiles[i],
                if (i != tiles.length - 1)
                  const Divider(height: 1, color: Color(0xFFD3E6F5)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.ink,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: color.withValues(alpha: 0.6)),
            ],
          ),
        ),
      ),
    );
  }
}
