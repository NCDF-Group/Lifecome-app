import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';

/// The launch screen: the LifeCome Live mark, animating in, while
/// [SessionStore] is checked in the background for a remembered session.
/// [_holdDuration] is a floor on how long this screen stays up (so the logo
/// animation is never cut short on a fast device), not the whole wait —
/// navigation happens once both the hold and the session check are done.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _holdDuration = Duration(milliseconds: 1400);

  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = Tween<double>(
      begin: 0.85,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();

    _resolveDestination();
  }

  Future<void> _resolveDestination() async {
    // The session read is near-instant (SharedPreferences on disk), so
    // running it before the hold effectively just adds it to the same wait
    // rather than lengthening the splash screen.
    final session = await ref.read(sessionStoreProvider).read();
    await Future<void>.delayed(_holdDuration);
    if (!mounted) return;
    context.go(session != null ? RoutePaths.appLock : RoutePaths.welcome);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: ScaleTransition(
            scale: _scale,
            child: SvgPicture.asset(
              'assets/images/logo/lifecome-live-logo.svg',
              height: 40,
              semanticsLabel: 'LifeCome Live',
            ),
          ),
        ),
      ),
    );
  }
}
