import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/services/session_store.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../auth/application/auth_controller.dart';

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
    final firstName = (_session?.displayName ?? 'Your account')
        .split(' ')
        .first;

    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            SvgPicture.asset(
              context.palette.logoAsset,
              height: 24,
              semanticsLabel: 'LifeCome Live',
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
            _ProfileRow(
              green: false,
              icon: Icons.person,
              title: firstName,
              subtitle: 'Personal account',
              onTap: () => context.push(RoutePaths.editProfile),
            ),
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
