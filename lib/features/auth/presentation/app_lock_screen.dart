import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/animation/fade_in.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/layout/auth_form_card.dart';
import '../application/auth_controller.dart';

enum _UnlockStep { idle, checking, unlocked }

/// Shown instead of the welcome screen when [SessionStore] remembers a
/// session from a previous launch. Unlocks with Face ID/fingerprint (tried
/// automatically once biometrics are available) or, as a fallback, the
/// account password — there is no auth-state check on launch otherwise (see
/// SplashScreen), so this screen is the only gate protecting a remembered
/// session.
class AppLockScreen extends ConsumerStatefulWidget {
  const AppLockScreen({super.key});

  @override
  ConsumerState<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends ConsumerState<AppLockScreen> {
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _passwordError;
  bool _passwordSubmitting = false;
  _UnlockStep _step = _UnlockStep.idle;
  String? _email;
  String? _displayName;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final session = await ref.read(sessionStoreProvider).read();
    final available = await ref.read(biometricServiceProvider).isAvailable();
    if (!mounted) return;
    setState(() {
      _email = session?.email;
      _displayName = session?.displayName;
      _biometricAvailable = available;
    });
    if (available) _tryBiometric();
  }

  Future<void> _tryBiometric() async {
    setState(() => _step = _UnlockStep.checking);
    final success = await ref.read(biometricServiceProvider).authenticate();
    if (!mounted) return;
    // A fingerprint proves it's you, but the backend still needs a valid session token. If it's gone
    // (expired, or this device never stored one), fall back to the password.
    if (success && ref.read(apiClientProvider).accessToken == null) {
      setState(() {
        _step = _UnlockStep.idle;
        _passwordError = 'Enter your password to continue.';
      });
      return;
    }
    if (success) {
      setState(() => _step = _UnlockStep.unlocked);
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (mounted) context.go(RoutePaths.home);
    } else {
      setState(() => _step = _UnlockStep.idle);
    }
  }

  Future<void> _unlockWithPassword() async {
    final email = _email;
    if (email == null) return;
    final password = _passwordController.text;

    setState(() {
      _passwordError = password.isEmpty ? 'Enter your password.' : null;
    });
    if (_passwordError != null) return;

    setState(() => _passwordSubmitting = true);
    final success = await ref
        .read(authControllerProvider.notifier)
        .signIn(email: email, password: password);
    if (!mounted) return;
    setState(() => _passwordSubmitting = false);

    if (success) {
      context.go(
        ref.read(authControllerProvider).needsProfile
            ? RoutePaths.completeProfile
            : RoutePaths.home,
      );
    } else {
      final message = ref.read(authControllerProvider).errorMessage;
      setState(() => _passwordError = message ?? 'Incorrect password.');
    }
  }

  Future<void> _signInWithAnotherAccount() async {
    await ref.read(sessionStoreProvider).clear();
    if (!mounted) return;
    context.go(RoutePaths.signIn);
  }

  @override
  Widget build(BuildContext context) {
    final name = _displayName;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
          child: AuthFormCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeIn(
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/images/logo/lifecome-live-logo.svg',
                      height: 32,
                      semanticsLabel: 'LifeCome Live',
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                FadeIn(
                  delay: const Duration(milliseconds: 80),
                  child: Text.rich(
                    TextSpan(
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                        height: 1.15,
                      ),
                      children: [
                        const TextSpan(text: 'Welcome back, '),
                        TextSpan(
                          text: '${name ?? ''},',
                          style: const TextStyle(color: AppColors.blue),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                const FadeIn(
                  delay: Duration(milliseconds: 120),
                  child: Text(
                    'Enter password or unlock with biometrics to continue.',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.inkMuted,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                FadeIn(
                  delay: const Duration(milliseconds: 160),
                  child: AppTextField(
                    label: 'Password',
                    controller: _passwordController,
                    hintText: 'Enter your password',
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    prefixIcon: Icons.lock_outline,
                    errorText: _passwordError,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                        color: AppColors.inkMuted,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    onSubmitted: (_) => _unlockWithPassword(),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                FadeIn(
                  delay: const Duration(milliseconds: 200),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push(RoutePaths.forgotPassword),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: AppColors.blue,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                FadeIn(
                  delay: const Duration(milliseconds: 240),
                  child: PrimaryButton(
                    label: 'Unlock',
                    loading: _passwordSubmitting,
                    onPressed: _unlockWithPassword,
                  ),
                ),
                if (_biometricAvailable) ...[
                  const SizedBox(height: AppSpacing.xl),
                  FadeIn(
                    delay: const Duration(milliseconds: 280),
                    child: Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _step == _UnlockStep.checking
                                ? null
                                : _tryBiometric,
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color:
                                    (_step == _UnlockStep.unlocked
                                            ? AppColors.green
                                            : AppColors.blue)
                                        .withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: _step == _UnlockStep.checking
                                  ? const Padding(
                                      padding: EdgeInsets.all(22),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        color: AppColors.blue,
                                      ),
                                    )
                                  : Icon(
                                      _step == _UnlockStep.unlocked
                                          ? Icons.check_circle
                                          : Icons.face_retouching_natural,
                                      color: _step == _UnlockStep.unlocked
                                          ? AppColors.greenStrong
                                          : AppColors.blue,
                                      size: 34,
                                    ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          const Text(
                            'Use Face ID',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                FadeIn(
                  delay: const Duration(milliseconds: 300),
                  child: Center(
                    child: TextButton(
                      onPressed: _signInWithAnotherAccount,
                      child: const Text(
                        'Not you? Sign in with another account',
                        style: TextStyle(
                          color: AppColors.inkMuted,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
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
