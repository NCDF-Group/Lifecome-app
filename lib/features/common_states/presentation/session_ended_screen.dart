import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/feedback/recovery_view.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/media/lc_icons.dart';

/// "Your session has ended" (screen pack 149): shown when the backend stops
/// accepting the saved sign-in, before going back to sign in.
class SessionEndedScreen extends StatelessWidget {
  const SessionEndedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: context.palette.background,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 25),
            children: [
              const AppHeaderBar(showBell: false),
              const SizedBox(height: 40),
              RecoveryView(
                icon: LcIcons.lock,
                title: 'Your session has ended',
                message:
                    'For your security, you’ve been signed out. Sign in again '
                    'to carry on where you left off.',
                primaryLabel: 'Sign in again',
                onPrimary: () => context.go(RoutePaths.signIn),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
