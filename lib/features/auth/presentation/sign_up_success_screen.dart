import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import 'widgets/auth_success_view.dart';

/// Shown once [CreatePasswordScreen] finishes sign-up.
class SignUpSuccessScreen extends StatelessWidget {
  const SignUpSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthSuccessView(
      title: 'Your account is ready!',
      message: 'Continue to start booking care and managing your health with LifeCome Live.',
      buttonLabel: 'Continue',
      onContinue: () => context.go(RoutePaths.home),
    );
  }
}
