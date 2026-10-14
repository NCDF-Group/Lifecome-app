import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/services/session_store.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_mode_controller.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/layout/app_bar_back.dart';
import '../../auth/application/auth_controller.dart';
import '../application/profile_controller.dart';
import 'widgets/my_avatar.dart';

/// The Profile tab landing screen — account summary plus links into health
/// records, support and account management.
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
    await ref.read(sessionManagerProvider).end();
    ref.read(authControllerProvider.notifier).reset();
    if (mounted) context.go(RoutePaths.welcome);
  }

  Future<void> _chooseAppearance() async {
    final mode = await showAppearancePopup(
      context,
      current: ref.read(themeModeProvider),
    );
    if (mode != null) {
      await ref.read(themeModeProvider.notifier).set(mode);
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final message = await showConfirmPopup(
      context,
      title: 'Delete your account?',
      message:
          "Account deletion isn't available in the app yet. Message patient "
          'support and they will delete your account and the information we '
          'hold about you.',
      confirmLabel: 'Message support',
    );
    if (message && mounted) context.push(RoutePaths.newMessage);
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(meProvider);
    final name = me.value?.displayName ?? _session?.displayName;
    final email = me.value?.account.email ?? _session?.email;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Row(
              children: [
                // The Profile tab is a tab root, so there is nothing behind
                // it: back goes Home.
                const AppBackButton(fallback: RoutePaths.home),
                const SizedBox(width: 8),
                SvgPicture.asset(
                  context.palette.logoAsset,
                  height: 24,
                  semanticsLabel: 'LifeCome Live',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Your profile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: context.palette.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage your account and preferences.',
              style: TextStyle(fontSize: 14, color: context.palette.inkMuted),
            ),
            const SizedBox(height: AppSpacing.md),
            _AccountCard(
              name: name,
              email: email,
              onTap: () => context.push(RoutePaths.editProfile),
            ),
            if (me.value?.needsProfile ?? false) ...[
              const SizedBox(height: AppSpacing.sm),
              _ProfileNudge(
                onTap: () => context.push(RoutePaths.completeProfile),
              ),
            ] else if (me.hasError && !me.hasValue) ...[
              const SizedBox(height: AppSpacing.sm),
              _LoadFailed(
                error: me.error!,
                onRetry: () => ref.read(meProvider.notifier).refresh(),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            _ProfileRow(
              green: true,
              icon: Icons.person_outline,
              title: 'Personal details',
              subtitle: 'View and update your personal information.',
              onTap: () => context.push(RoutePaths.editProfile),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ProfileRow(
              green: false,
              icon: Icons.monitor_heart_outlined,
              title: 'Medical history',
              subtitle: 'Add and manage your medical history.',
              onTap: () =>
                  showComingSoonPopup(context, feature: 'Medical history'),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ProfileRow(
              green: true,
              icon: Icons.workspace_premium_outlined,
              title: 'Access and benefits',
              subtitle: 'View your access and available benefits.',
              onTap: () => context.push(RoutePaths.myBenefits),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ProfileRow(
              green: false,
              icon: Icons.groups_outlined,
              title: 'Household membership',
              subtitle: 'Manage household members and their access.',
              onTap: () => context.push(RoutePaths.membershipBilling),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ProfileRow(
              green: true,
              icon: Icons.description_outlined,
              title: 'Health records',
              subtitle: 'View and manage your records and care plans.',
              onTap: () => context.push(RoutePaths.healthRecords),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ProfileRow(
              green: false,
              icon: Icons.verified_user_outlined,
              title: 'Privacy and sharing',
              subtitle: 'Manage your data, privacy and sharing preferences.',
              onTap: () => context.push(RoutePaths.privacyAndSharing),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ProfileRow(
              green: true,
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Choose what you want to be notified about.',
              onTap: () => showComingSoonPopup(
                context,
                feature: 'Notification settings',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ProfileRow(
              green: false,
              icon: Icons.brightness_6_outlined,
              title: 'Appearance',
              subtitle: switch (themeMode) {
                ThemeMode.system =>
                  "Matches your phone's light or dark setting.",
                ThemeMode.light => 'Always light.',
                ThemeMode.dark => 'Always dark.',
              },
              onTap: _chooseAppearance,
            ),
            const SizedBox(height: AppSpacing.sm),
            _ProfileRow(
              green: true,
              icon: Icons.help_outline,
              title: 'Help and support',
              subtitle: 'Get help, view FAQs or contact support.',
              onTap: () => context.push(RoutePaths.helpAndSupport),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ProfileRow(
              destructive: true,
              icon: Icons.logout,
              title: 'Sign out',
              subtitle: 'Sign out of your account on this device.',
              onTap: _signOut,
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _FooterLink(
                    label: 'Privacy Policy',
                    onTap: () => context.push(RoutePaths.privacyPolicy),
                  ),
                  const _FooterDot(),
                  _FooterLink(
                    label: 'Terms and Conditions',
                    onTap: () => context.push(RoutePaths.termsAndConditions),
                  ),
                  const _FooterDot(),
                  _FooterLink(
                    label: 'Delete my account',
                    color: context.palette.danger,
                    onTap: _confirmDeleteAccount,
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

/// Who is signed in: their photo (or real initials), name and email.
class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.name,
    required this.email,
    required this.onTap,
  });

  final String? name;
  final String? email;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.palette.tintBlue,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              MyAvatar(radius: 26, fallbackName: name),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name ?? 'Your account',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: context.palette.ink,
                      ),
                    ),
                    if (email != null)
                      Text(
                        email!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
    );
  }
}

/// Shown when the account has no profile yet: booking needs one.
class _ProfileNudge extends StatelessWidget {
  const _ProfileNudge({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.palette.tintAmber,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: context.palette.amber),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Finish setting up your profile to book care.',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: context.palette.ink,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: context.palette.inkMuted),
            ],
          ),
        ),
      ),
    );
  }
}

/// The profile could not be loaded; the rest of the tab still works.
class _LoadFailed extends StatelessWidget {
  const _LoadFailed({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final message = error is ApiException
        ? (error as ApiException).message
        : "We couldn't load your details.";
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.palette.tintRed,
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 18, color: context.palette.danger),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12.5, color: context.palette.ink),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.green = false,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool green;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final background = destructive
        ? context.palette.tintRed
        : (green ? context.palette.tintGreen : context.palette.tintBlue);
    final tint = destructive
        ? context.palette.danger
        : (green ? context.palette.positive : context.palette.accent);
    final titleColor = destructive
        ? context.palette.danger
        : context.palette.ink;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: context.palette.elevated,
                child: Icon(icon, color: tint),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: context.palette.inkMuted,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: tint),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label, required this.onTap, this.color});

  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: color ?? context.palette.inkMuted,
          ),
        ),
      ),
    );
  }
}

class _FooterDot extends StatelessWidget {
  const _FooterDot();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        '·',
        style: TextStyle(fontSize: 12.5, color: context.palette.inkMuted),
      ),
    );
  }
}
