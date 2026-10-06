import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import 'widgets/auth_success_view.dart';

/// Shown once [NewPasswordScreen] finishes the forgot-password flow.
class PasswordChangedScreen extends StatelessWidget {
  const PasswordChangedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthSuccessView(
      title: 'Password Changed!',
      message: 'Continue to the login page to regain access to your account.',
      buttonLabel: 'Login',
      onContinue: () => context.go(RoutePaths.signIn),
    );
  }
}
