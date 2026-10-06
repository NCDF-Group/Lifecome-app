import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/auth_repository.dart';
import '../domain/models/auth_session.dart';

const _resendCooldown = Duration(seconds: 30);

/// Holds the state for the sign-in, create-account and verify-email screens.
/// One controller for the whole flow, since the three screens are really one
/// journey: request a code, then verify it.
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
            .save(email: email, displayName: _displayNameFor(email, state.fullName));
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

  Future<bool> requestCode({
    required AuthFlow flow,
    required String email,
    String? fullName,
    String? referralCode,
    String? phoneNumber,
    DateTime? dateOfBirth,
  }) async {
    state = state.copyWith(
      status: AuthStatus.submitting,
      flow: flow,
      email: email,
      fullName: fullName,
      clearError: true,
    );

    try {
      await ref.read(authRepositoryProvider).requestEmailCode(
            email: email,
            fullName: fullName,
            referralCode: referralCode,
            phoneNumber: phoneNumber,
            dateOfBirth: dateOfBirth,
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

  Future<bool> verifyCode(String code) async {
    state = state.copyWith(status: AuthStatus.verifying, clearError: true);

    try {
      await ref
          .read(authRepositoryProvider)
          .verifyEmailCode(email: state.email, code: code);
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

  /// Sets the new account's password, finishing sign-up. Only valid after
  /// [verifyCode] has succeeded for the current [AuthSessionState.email].
  Future<bool> completeSignUp(String password) async {
    state = state.copyWith(status: AuthStatus.submitting, clearError: true);

    try {
      await ref
          .read(authRepositoryProvider)
          .completeSignUp(email: state.email, password: password);
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
          .resendEmailCode(email: state.email);
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
