import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/animation/fade_in.dart';
import '../../../core/country/app_country.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/services/session_store.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/feedback/app_popup.dart';

/// The LifeCome Live Dashboard — blueprint view 04, the Home tab of the
/// bottom-nav shell. Matches the "new patient, nothing booked yet" state:
/// once a patient has an upcoming visit or an active care plan, those
/// replace the access-options section (not built yet — no booking backend
/// exists for this to reflect).
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  StoredSession? _session;

  @override
  void initState() {
    super.initState();
    ref.read(sessionStoreProvider).read().then((session) {
      if (mounted) setState(() => _session = session);
    });
  }

  String get _firstName {
    final name = _session?.displayName;
    if (name == null || name.isEmpty) return 'there';
    return name.split(' ').first;
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0, 0.22, 0.42],
            colors: [Color(0xFFE8F4FC), Color(0xFFEAF7E8), AppColors.white],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/logo/lifecome-live-logo.svg',
                    height: 26,
                    semanticsLabel: 'LifeCome Live',
                  ),
                  const Spacer(),
                  const _CountryBadge(),
                  const SizedBox(width: AppSpacing.xs),
                  _NotificationBell(
                    onTap: () => showNotificationsPopup(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              FadeIn(
                child: Text(
                  '$_greeting, $_firstName',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkMuted,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              FadeIn(
                delay: const Duration(milliseconds: 40),
                child: Text.rich(
                  const TextSpan(
                    style: TextStyle(
                      fontSize: 29,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                      height: 1.15,
                      letterSpacing: -0.5,
                    ),
                    children: [
                      TextSpan(text: 'Care that fits '),
                      TextSpan(
                        text: 'your life',
                        style: TextStyle(color: AppColors.greenStrong),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FadeIn(
                delay: const Duration(milliseconds: 80),
                child: const _TalkToADoctorCard(),
              ),
              const SizedBox(height: AppSpacing.lg),
              FadeIn(
                delay: const Duration(milliseconds: 100),
                child: _PromoSlider(
                  onTapSlide: () => showComingSoonPopup(context),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              FadeIn(
                delay: const Duration(milliseconds: 120),
                child: const Text(
                  'How would you like to access care?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              FadeIn(
                delay: const Duration(milliseconds: 150),
                child: _AccessOptionCard(
                  filled: true,
                  icon: Icons.health_and_safety_rounded,
                  title: 'Use my LifeCome HMO',
                  subtitle: 'Access care covered by your plan',
                  onTap: () => context.push(RoutePaths.payerSelectHmo),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              FadeIn(
                delay: const Duration(milliseconds: 180),
                child: _AccessOptionCard(
                  filled: false,
                  icon: Icons.account_balance_wallet_rounded,
                  title: 'Pay for a one-time service',
                  subtitle: 'No HMO membership needed',
                  onTap: () =>
                      context.push(RoutePaths.payerChoosePaymentMethod),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              FadeIn(
                delay: const Duration(milliseconds: 210),
                child: const Text(
                  'Your care, in one place',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              FadeIn(
                delay: const Duration(milliseconds: 240),
                // IntrinsicHeight gives the row a finite height so `stretch`
                // can match the two cards; a ListView child is unbounded.
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _SmallActionCard(
                          background: const Color(0xFFEAF7E8),
                          iconColor: AppColors.greenStrong,
                          icon: Icons.calendar_month_rounded,
                          title: 'My visits',
                          subtitle: 'View and manage your appointments',
                          onTap: () => context.go(RoutePaths.visits),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _SmallActionCard(
                          background: const Color(0xFFE8F4FC),
                          iconColor: AppColors.blue,
                          icon: Icons.favorite_rounded,
                          title: 'My care plan',
                          subtitle: 'Track your health goals and progress',
                          onTap: () => context.push(RoutePaths.careplan),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              FadeIn(
                delay: const Duration(milliseconds: 270),
                child: _UrgentHelpBanner(
                  onTap: () => showComingSoonPopup(
                    context,
                    feature: 'Emergency guidance',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A soft, blurred accent circle — the same "glow" treatment `BrandBackdrop`
/// uses on auth screens, scaled down and clipped to sit inside a card
/// instead of behind a whole screen.
class _CardGlow extends StatelessWidget {
  const _CardGlow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

/// The user's country (flag + name) in the header. Tapping it lets them
/// switch between the countries LifeCome Live serves.
class _CountryBadge extends ConsumerWidget {
  const _CountryBadge();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final country = ref.watch(countryProvider);

    return Material(
      color: AppColors.white.withValues(alpha: 0.85),
      shape: const StadiumBorder(side: BorderSide(color: AppColors.line)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () async {
          final picked = await showCountryPickerPopup(
            context,
            current: country,
          );
          if (picked != null) {
            ref.read(countryProvider.notifier).select(picked);
          }
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 7, 8, 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(country.flag, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(
                country.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppColors.inkMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.blue.withValues(alpha: 0.08),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.notifications_rounded,
                color: AppColors.blue,
                size: 22,
              ),
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: AppColors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TalkToADoctorCard extends StatelessWidget {
  const _TalkToADoctorCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEAF6FF), Color(0xFFD9EDFB)],
          ),
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: [
            BoxShadow(
              color: AppColors.blue.withValues(alpha: 0.10),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          // The photo reaches into the card's padding so it sits flush with
          // the bottom and right edges; the ClipRRect above trims it.
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: -30,
              top: -30,
              child: _CardGlow(
                color: AppColors.cyan.withValues(alpha: 0.22),
                size: 120,
              ),
            ),
            Positioned(
              right: 10,
              bottom: -20,
              child: _CardGlow(
                color: AppColors.lime.withValues(alpha: 0.18),
                size: 90,
              ),
            ),
            Positioned(
              top: -AppSpacing.xs,
              right: -AppSpacing.md,
              bottom: -AppSpacing.md,
              width: 150,
              child: Image.asset(
                'assets/images/home/doctor.png',
                fit: BoxFit.contain,
                alignment: Alignment.bottomRight,
                semanticLabel: 'A LifeCome Live doctor',
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Talk to a doctor',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      const Text(
                        'From wherever you are',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.blue,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const _FeatureRow(
                        icon: Icons.videocam_rounded,
                        label: 'Video consultations',
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      const _FeatureRow(
                        icon: Icons.call_rounded,
                        label: 'Phone calls',
                        color: AppColors.greenStrong,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      const _FeatureRow(
                        icon: Icons.chat_bubble_rounded,
                        label: 'Secure messaging',
                      ),
                    ],
                  ),
                ),
                // Room for the doctor photo, drawn by the Stack below.
                const Spacer(flex: 2),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoSlide {
  const _PromoSlide({
    required this.image,
    required this.title,
    required this.subtitle,
  });

  final String image;
  final String title;
  final String subtitle;
}

const _promoSlides = [
  _PromoSlide(
    image: 'assets/images/home/promo-1.png',
    title: 'Talk to a doctor',
    subtitle: 'Video consultations, anytime',
  ),
  _PromoSlide(
    image: 'assets/images/home/promo-2.png',
    title: 'Covered by your HMO',
    subtitle: 'Check your plan and book care',
  ),
  _PromoSlide(
    image: 'assets/images/home/promo-3.png',
    title: 'Your care, in one place',
    subtitle: 'Records, prescriptions, follow-ups',
  ),
];

/// A swipeable promo carousel beneath the hero card — announcements, offers
/// or seasonal campaigns. Backed by static assets for now (no CMS/promo
/// backend exists yet), so the three slides are fixed.
class _PromoSlider extends StatefulWidget {
  const _PromoSlider({required this.onTapSlide});

  final VoidCallback onTapSlide;

  @override
  State<_PromoSlider> createState() => _PromoSliderState();
}

class _PromoSliderState extends State<_PromoSlider> {
  static const _autoSlideEvery = Duration(seconds: 4);

  // The PageView is "infinite": it starts far into a large page range and
  // maps each index back onto the three slides, so auto-sliding can always
  // move forward and wrap from the last slide to the first without
  // rewinding.
  static const _loopStart = 3000;
  final _controller = PageController(initialPage: _loopStart);
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _timer?.cancel();
    _timer = Timer.periodic(_autoSlideEvery, (_) {
      if (!_controller.hasClients) return;
      _controller.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // One rounded container holds the slides: each slide fills it exactly
        // and the container clips them, so nothing ever spills past its
        // edges while sliding. The shadow sits on the container, not on the
        // slides, so clipping doesn't cut it off.
        Container(
          height: 130,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.card),
            // Pause auto-sliding while the user drags, and restart the countdown
            // once they let go so it never jumps right after a manual swipe.
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollStartNotification &&
                    notification.dragDetails != null) {
                  _timer?.cancel();
                } else if (notification is ScrollEndNotification) {
                  _startAutoSlide();
                }
                return false;
              },
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (index) =>
                    setState(() => _page = index % _promoSlides.length),
                itemBuilder: (context, index) =>
                    _buildSlideCard(_promoSlides[index % _promoSlides.length]),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _promoSlides.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _page ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _page ? AppColors.blue : AppColors.line,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSlideCard(_PromoSlide slide) {
    return Material(
      color: AppColors.blue,
      child: InkWell(
        onTap: widget.onTapSlide,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(slide.image, fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.black.withValues(alpha: 0.0),
                  ],
                  stops: const [0, 0.75],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    slide.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    slide.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.white.withValues(alpha: 0.9),
                    ),
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

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.label,
    this.color = AppColors.blue,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 13, color: color),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.ink)),
      ],
    );
  }
}

class _AccessOptionCard extends StatelessWidget {
  const _AccessOptionCard({
    required this.filled,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool filled;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = filled ? AppColors.white : AppColors.ink;
    final subtitleColor = filled
        ? AppColors.white.withValues(alpha: 0.85)
        : AppColors.inkMuted;
    final chipBackground = filled
        ? AppColors.white.withValues(alpha: 0.18)
        : const Color(0xFFFCF3E3);
    final accent = filled ? AppColors.white : AppColors.gold;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        gradient: filled
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.blue, AppColors.blueStrong],
              )
            : null,
        color: filled ? null : AppColors.white,
        border: filled ? null : Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: (filled ? AppColors.blue : Colors.black).withValues(
              alpha: filled ? 0.22 : 0.04,
            ),
            blurRadius: filled ? 20 : 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: chipBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: accent, size: 20),
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
                          fontWeight: FontWeight.w800,
                          color: foreground,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 13, color: subtitleColor),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: accent, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SmallActionCard extends StatelessWidget {
  const _SmallActionCard({
    required this.background,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Color background;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: iconColor, size: 18),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: iconColor,
                      size: 14,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UrgentHelpBanner extends StatelessWidget {
  const _UrgentHelpBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFCEAEA),
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emergency_rounded,
                    color: AppColors.error,
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Need urgent help?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.error,
                        ),
                      ),
                      Text(
                        'View emergency guidance',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.error,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
