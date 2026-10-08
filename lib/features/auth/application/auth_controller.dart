import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/auth_repository.dart';
import '../domain/models/auth_session.dart';

const _resendCooldown = Duration(seconds: 30);

/// Holds the state for the sign-in, create-account and verify-mobile screens.
/// One controller for the whole flow, since the three screens are really one
/// journey: register, then verify the code.
class AuthController extends Notifier<AuthSessionState> {
  @override
  AuthSessionState build() => AuthSessionState.empty();

  /// The first name to greet the user with (app-lock screen, session
  /// store). Falls back to the part of the email before "@" when no full
  /// name is known, since sign-in alone never collects one.
  String _displayNameFor(String email, String? fullName) {
    final parts = fullName?.trim().split(' ') ?? const <String>[];
    final firstName = parts.isNotEmpty ? parts.first : '';
    if (firstName.isNotEmpty) return firstName;
    final local = email.split('@').first;
    return local.isEmpty ? email : local[0].toUpperCase() + local.substring(1);
  }

  /// Email + password sign in. Unlike [requestCode], this resolves
  /// immediately, there is no separate verification step. [rememberMe]
  /// controls whether the session is persisted — unchecked, the app
  /// forgets this sign-in once it's closed, so the next launch goes back
  /// to the welcome screen instead of [AppLockScreen].
  Future<bool> signIn({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    state = state.copyWith(
      status: AuthStatus.submitting,
      flow: AuthFlow.signIn,
      email: email,
      clearError: true,
    );

    try {
      await ref
          .read(authRepositoryProvider)
          .signInWithPassword(email: email, password: password);
      if (rememberMe) {
        await ref
            .read(sessionStoreProvider)
            .save(
              email: email,
              displayName: _displayNameFor(email, state.fullName),
            );
      }
      state = state.copyWith(status: AuthStatus.verified);
      return true;
    } on AuthException catch (error) {
      state = state.copyWith(
        status: AuthStatus.failed,
        errorMessage: error.message,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.failed,
        errorMessage: 'Something went wrong. Please try again.',
      );
      return false;
    }
  }

  /// Registers with everything the single-page sign-up form collects, and
  /// triggers the first SMS code. The account already has its password at
  /// this point — [verifyCode] is sign-up's last step, not a separate
  /// "create password" screen after it.
  Future<bool> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    state = state.copyWith(
      status: AuthStatus.submitting,
      flow: AuthFlow.createAccount,
      email: email,
      fullName: '$firstName $lastName',
      clearError: true,
    );

    try {
      await ref
          .read(authRepositoryProvider)
          .register(
            firstName: firstName,
            lastName: lastName,
            email: email,
            phoneNumber: phoneNumber,
            password: password,
          );
      state = state.copyWith(
        status: AuthStatus.codeSent,
        resendAvailableAt: DateTime.now().add(_resendCooldown),
      );
      return true;
    } on AuthException catch (error) {
      state = state.copyWith(
        status: AuthStatus.failed,
        errorMessage: error.message,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.failed,
        errorMessage: 'Something went wrong. Please try again.',
      );
      return false;
    }
  }

  /// Verifies the SMS code and, since the password was already set at
  /// [signUp], signs the account straight in.
  Future<bool> verifyCode(String code) async {
    state = state.copyWith(status: AuthStatus.verifying, clearError: true);

    try {
      await ref
          .read(authRepositoryProvider)
          .verifyPhoneCode(email: state.email, code: code);
      await ref
          .read(sessionStoreProvider)
          .save(
            email: state.email,
            displayName: _displayNameFor(state.email, state.fullName),
          );
      state = state.copyWith(status: AuthStatus.verified);
      return true;
    } on AuthException catch (error) {
      state = state.copyWith(
        status: AuthStatus.codeSent,
        errorMessage: error.message,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.codeSent,
        errorMessage: 'Something went wrong. Please try again.',
      );
      return false;
    }
  }

  Future<void> resendCode() async {
    try {
      await ref
          .read(authRepositoryProvider)
          .resendPhoneCode(email: state.email);
      state = state.copyWith(
        resendAvailableAt: DateTime.now().add(_resendCooldown),
        clearError: true,
      );
    } on AuthException catch (error) {
      state = state.copyWith(errorMessage: error.message);
    } catch (_) {
      state = state.copyWith(
        errorMessage: 'Could not resend the code. Please try again.',
      );
    }
  }

  void reset() {
    state = AuthSessionState.empty();
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthSessionState>(AuthController.new);
