import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../../../core/widgets/buttons/ghost_button.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/lists/row_card.dart';
import '../../../core/widgets/media/lc_icons.dart';
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
        // Not a lazy ListView: the list is short, and everything on it (sign
        // out, the footer links) should always be there.
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // The Profile tab is a tab root, so there is nothing behind it:
              // back goes Home.
              const AppHeaderBar(showBack: true),
              const SizedBox(height: 4),
              const ScreenTitle(
                title: 'Your profile',
                subtitle: 'Your details and preferences.',
              ),
              const SizedBox(height: 16),
              _AccountCard(
                name: name,
                email: email,
                onTap: () => context.push(RoutePaths.editProfile),
              ),
              if (me.value?.needsProfile ?? false) ...[
                const SizedBox(height: 10),
                _ProfileNudge(
                  onTap: () => context.push(RoutePaths.completeProfile),
                ),
              ] else if (me.hasError && !me.hasValue) ...[
                const SizedBox(height: 10),
                _LoadFailed(
                  error: me.error!,
                  onRetry: () => ref.read(meProvider.notifier).refresh(),
                ),
              ],
              const SizedBox(height: 8),
              RowCard(
                icon: LcIcons.user,
                title: 'Personal details',
                subtitle: 'Your name, date of birth and town',
                onTap: () => context.push(RoutePaths.editProfile),
              ),
              RowCard(
                icon: LcIcons.care,
                title: 'Health profile',
                subtitle: 'Conditions, medicines and allergies',
                onTap: () => context.push(RoutePaths.healthProfile),
              ),
              RowCard(
                icon: LcIcons.file,
                title: 'Health records',
                subtitle: 'Notes, prescriptions, referrals and results',
                onTap: () => context.push(RoutePaths.healthRecords),
              ),
              RowCard(
                icon: LcIcons.shield,
                title: 'Membership & benefits',
                subtitle: 'Membership, employer access and cover',
                tone: RowCardTone.mint,
                onTap: () => context.push(RoutePaths.myBenefits),
              ),
              RowCard(
                icon: LcIcons.people,
                title: 'Household membership',
                subtitle: 'Household members and their access',
                tone: RowCardTone.mint,
                onTap: () => context.push(RoutePaths.membershipBilling),
              ),
              RowCard(
                icon: LcIcons.card,
                title: 'Payment methods',
                subtitle: 'How you pay for care',
                onTap: () => context.push(RoutePaths.paymentMethods),
              ),
              RowCard(
                icon: LcIcons.lock,
                title: 'Privacy & permissions',
                subtitle: 'Control sharing and preferences',
                onTap: () => context.push(RoutePaths.privacyAndSharing),
              ),
              RowCard(
                icon: LcIcons.bell,
                title: 'Notifications',
                subtitle: 'How you hear from us',
                onTap: () => context.push(RoutePaths.notificationSettings),
              ),
              RowCard(
                icon: LcIcons.settings,
                title: 'Accessibility',
                subtitle: 'Text size and motion',
                onTap: () => context.push(RoutePaths.accessibility),
              ),
              RowCard(
                icon: LcIcons.star,
                title: 'Appearance',
                subtitle: switch (themeMode) {
                  ThemeMode.system =>
                    "Matches your phone's light or dark setting",
                  ThemeMode.light => 'Always light',
                  ThemeMode.dark => 'Always dark',
                },
                onTap: _chooseAppearance,
              ),
              RowCard(
                icon: LcIcons.info,
                title: 'Help & support',
                subtitle: 'Get assistance or share feedback',
                onTap: () => context.push(RoutePaths.helpAndSupport),
              ),
              const SizedBox(height: 6),
              GhostButton(
                label: 'Sign out',
                color: context.palette.danger,
                onPressed: _signOut,
              ),
              const SizedBox(height: 10),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _FooterLink(
                      label: 'Privacy notice',
                      onTap: () => context.push(RoutePaths.privacyPolicy),
                    ),
                    const _FooterDot(),
                    _FooterLink(
                      label: 'Terms of use',
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
    final palette = context.palette;
    return Material(
      color: palette.tintBlue,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        borderRadius: BorderRadius.circular(19),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            children: [
              MyAvatar(radius: 39, fallbackName: name),
              const SizedBox(height: 12),
              Text(
                name ?? 'Your account',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: palette.ink,
                ),
              ),
              if (email != null) ...[
                const SizedBox(height: 3),
                Text(
                  email!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: palette.inkMuted),
                ),
              ],
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
