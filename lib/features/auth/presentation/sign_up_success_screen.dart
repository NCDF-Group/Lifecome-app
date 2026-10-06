import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../application/auth_controller.dart';
import 'widgets/auth_success_view.dart';

/// Shown once [CreatePasswordScreen] finishes sign-up.
class SignUpSuccessScreen extends ConsumerWidget {
  const SignUpSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AuthSuccessView(
      title: 'Your account is ready!',
      message: 'Continue to start booking care and managing your health with LifeCome Live.',
      buttonLabel: 'Continue',
      // If the profile couldn't be saved during sign-up, ask for it before going Home.
      onContinue: () => context.go(
        ref.read(authControllerProvider).needsProfile
            ? RoutePaths.completeProfile
            : RoutePaths.home,
      ),
    );
  }
}
