import 'package:flutter/material.dart';

import '../../../core/theme/app_typography.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/animation/fade_in.dart';
import '../../../core/country/app_country.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_svg_icons.dart';
import '../../../core/widgets/design/soft_widgets.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../booking/application/access_status.dart';
import '../application/location_confirmation.dart';
import 'widgets/home_header.dart';

/// The Home tab: greeting header, the two ways to get care, the "Your Care"
/// call to action, a membership banner and quick links.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Future<void> _pickCountry() async {
    final picked = await showCountryPickerPopup(
      context,
      current: ref.read(countryProvider),
    );
    if (picked != null) {
      await ref.read(countryProvider.notifier).select(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final country = ref.watch(countryProvider);
    final locationConfirmed = ref.watch(locationConfirmationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: [
            const HomeHeader(),
            if (!locationConfirmed) ...[
              const SizedBox(height: 20),
              FadeIn(
                child: _LocationBlock(
                  location: country.name,
                  onConfirm: () =>
                      ref.read(locationConfirmationProvider.notifier).confirm(),
                  onUpdate: _pickCountry,
                  onUseDevice: () =>
                      showComingSoonPopup(context, feature: 'Device location'),
                ),
              ),
            ],
            SizedBox(height: locationConfirmed ? 28 : 36),
            FadeIn(child: const _Headline()),
            const SizedBox(height: 22),
            FadeIn(
              delay: const Duration(milliseconds: 60),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _ServiceCard(
                        image: 'assets/images/home/online-gp.png',
                        title: 'Online GP',
                        subtitle: 'Speak to a GP by video or phone.',
                        onTap: () => context.go(RoutePaths.book),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ServiceCard(
                        image: 'assets/images/home/smart-clinic.png',
                        title: 'Smart GP Clinic',
                        subtitle: 'In-person care at a local clinic.',
                        onTap: () => context.go(RoutePaths.book),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            FadeIn(
              delay: const Duration(milliseconds: 120),
              child: _YourCareCard(onTap: () => context.go(RoutePaths.book)),
            ),
            const SizedBox(height: 32),
            FadeIn(
              delay: const Duration(milliseconds: 180),
              child: _MembershipBanner(
                pending:
                    ref.watch(accessStatusProvider) == AccessStatus.pending,
                onTap: () => context.go(RoutePaths.book),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Quick Links',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.heading,
              ),
            ),
            const SizedBox(height: 14),
            FadeIn(
              delay: const Duration(milliseconds: 240),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _QuickLink(
                        glyph: AppSvgGlyph.briefcaseBold,
                        color: AppColors.actionBlue,
                        label: 'My access',
                        onTap: () => context.go(RoutePaths.bookConnectAccess),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickLink(
                        glyph: AppSvgGlyph.calendarSearchBold,
                        color: const Color(0xFFA2D610),
                        label: 'Appointments',
                        onTap: () => context.push(RoutePaths.visits),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickLink(
                        glyph: AppSvgGlyph.noteBold,
                        color: const Color(0xFF49AA02),
                        label: 'Care Plan',
                        onTap: () => context.go(RoutePaths.careplan),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Headline extends StatelessWidget {
  const _Headline();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Care online or in person',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Access quality healthcare in a way that works for you.',
          style: TextStyle(
            fontSize: 14,
            letterSpacing: -0.2,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String image;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // The artwork has its own pale background, so this card stays light in dark mode too.
    return SoftCard(
      onTap: onTap,
      fill: AppColors.illustrationFill,
      borderColor: const Color(0xFFD7DAE0),
      padding: const EdgeInsets.fromLTRB(18, 20, 14, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 80,
            width: double.infinity,
            child: Image.asset(
              image,
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: AppColors.onIllustration,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.45,
              letterSpacing: -0.2,
              color: AppColors.onIllustrationMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _YourCareCard extends StatelessWidget {
  const _YourCareCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.tintBlue,
                ),
                child: const AppSvgIcon(
                  AppSvgGlyph.calendarBold,
                  size: 24,
                  color: AppColors.actionBlue,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Care',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'See available services and appointment times.',
                      style: TextStyle(
                        fontSize: 13,
                        letterSpacing: -0.2,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.actionBlue,
                foregroundColor: AppColors.white,
                shape: const StadiumBorder(),
                textStyle: const TextStyle(
                  fontFamily: appFontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.3,
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Find an appointment'),
                  SizedBox(width: 12),
                  AppSvgIcon(AppSvgGlyph.chevronLine, size: 22),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MembershipBanner extends StatelessWidget {
  const _MembershipBanner({required this.pending, required this.onTap});

  /// True while a funded-access check is awaiting approval.
  final bool pending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      radius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          AppSvgIcon(
            pending ? AppSvgGlyph.heartPlusBold : AppSvgGlyph.calendarBold,
            size: 24,
            color: pending ? AppColors.green : AppColors.actionBlue,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: pending
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HMO route - approval pending',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.3,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Pay per visit - no membership required.',
                        style: TextStyle(
                          fontSize: 14,
                          letterSpacing: -0.2,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  )
                : Text(
                    'Membership optional - pay per visit',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.3,
                      color: AppColors.textPrimary,
                    ),
                  ),
          ),
          const AppSvgIcon(
            AppSvgGlyph.chevronLine,
            size: 22,
            color: AppColors.actionBlue,
          ),
        ],
      ),
    );
  }
}

class _QuickLink extends StatelessWidget {
  const _QuickLink({
    required this.glyph,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final AppSvgGlyph glyph;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      fill: AppColors.background,
      radius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppSvgIcon(glyph, size: 34, color: color),
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.3,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The "Suggested location - please confirm" block shown at the top of Home
/// until the user confirms (or changes) their location.
class _LocationBlock extends StatelessWidget {
  const _LocationBlock({
    required this.location,
    required this.onConfirm,
    required this.onUpdate,
    required this.onUseDevice,
  });

  final String location;
  final VoidCallback onConfirm;
  final VoidCallback onUpdate;
  final VoidCallback onUseDevice;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SoftCard(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.tintBlue,
                    ),
                    child: const AppSvgIcon(
                      AppSvgGlyph.pinBold,
                      size: 24,
                      color: AppColors.actionBlue,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Suggested location - please confirm.',
                          style: TextStyle(
                            fontSize: 13,
                            letterSpacing: -0.2,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: onConfirm,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.actionBlue,
                    foregroundColor: AppColors.white,
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(
                      fontFamily: appFontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.3,
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Confirm Location'),
                      SizedBox(width: 12),
                      AppSvgIcon(AppSvgGlyph.chevronLine, size: 22),
                    ],
                  ),
                ),
              ),
              TextButton(
                onPressed: onUpdate,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.actionBlue,
                  minimumSize: const Size.fromHeight(48),
                  textStyle: const TextStyle(
                    fontFamily: appFontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.3,
                  ),
                ),
                child: const Text('Location incorrect? Update it'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 50,
          child: OutlinedButton(
            onPressed: onUseDevice,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.actionBlue,
              side: const BorderSide(color: AppColors.actionBlue),
              shape: const StadiumBorder(),
              textStyle: const TextStyle(
                fontFamily: appFontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.3,
              ),
            ),
            child: const Row(
              children: [
                SizedBox(width: 12),
                AppSvgIcon(AppSvgGlyph.targetLine, size: 24),
                Expanded(
                  child: Text(
                    'Use device location',
                    textAlign: TextAlign.center,
                  ),
                ),
                AppSvgIcon(AppSvgGlyph.chevronLine, size: 22),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'With your permission, find nearby clinics.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            letterSpacing: -0.2,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        SoftCard(
          radius: 12,
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSvgIcon(
                AppSvgGlyph.infoBold,
                size: 22,
                color: AppColors.actionBlue,
              ),
              SizedBox(width: 14),
              Expanded(
                child: Text(
                  'We use your location to show relevant services. We do not '
                  'track you in the background or automatically upload your '
                  'full address.',
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.4,
                    letterSpacing: -0.2,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
