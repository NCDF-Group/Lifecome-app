import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import 'widgets/auth_success_view.dart';

/// Shown once [VerifyEmailScreen] finishes sign-up.
class SignUpSuccessScreen extends StatelessWidget {
  const SignUpSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthSuccessView(
      title: 'Your account is ready!',
      message: 'One last step: tell us a little about you, then you can start booking care with LifeCome Live.',
      buttonLabel: 'Continue',
      onContinue: () => context.go(RoutePaths.completeProfile),
    );
  }
}
