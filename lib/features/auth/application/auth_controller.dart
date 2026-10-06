import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/country/app_country.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../notifications/application/notifications_controller.dart';
import '../../profile/application/avatar_controller.dart';
import '../data/auth_repository.dart';
import '../domain/models/auth_session.dart';

const _resendCooldown = Duration(seconds: 30);

/// Holds the state for the sign-in, create-account and verify-email screens.
/// One controller for the whole flow, since the three screens are really one
/// journey: request a code, then verify it.
class AuthController extends Notifier<AuthSessionState> {
  @override
  AuthSessionState build() => AuthSessionState.empty();

  /// The first name to greet the user with (app-lock screen, session store). Only a fallback for
  /// when the backend has no profile for the account yet - the real name comes from `GET /me`.
  String _fallbackName(String email) {
    final local = email.split('@').first;
    return local.isEmpty ? email : local[0].toUpperCase() + local.substring(1);
  }

  /// Loads the signed-in account's profile and remembers the session - with the real first name,
  /// never the email. Returns whether the account still needs its profile created.
  Future<bool> _rememberSession(String email) async {
    final client = ref.read(apiClientProvider);
    var name = _fallbackName(email);
    var needsProfile = true;
    try {
      final me = await ref.read(profileRepositoryProvider).getMe();
      final profile = me.profile;
      if (profile != null) {
        name = profile.firstName;
        needsProfile = false;
      }
    } on ApiException {
      // Offline or a hiccup: keep the fallback name; the next sign-in refreshes it.
      needsProfile = false;
    }
    await ref
        .read(sessionStoreProvider)
        .save(email: email, displayName: name, accessToken: client.accessToken);
    return needsProfile;
  }

  /// Whether the signed-in account has no profile yet. A network failure counts as "no" so a flaky
  /// connection never traps someone on the profile form.
  Future<bool> _profileMissing() async {
    try {
      return (await ref.read(profileRepositoryProvider).getMe()).profile ==
          null;
    } on ApiException {
      return false;
    }
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
      var needsProfile = false;
      if (rememberMe) {
        needsProfile = await _rememberSession(email);
      } else {
        needsProfile = await _profileMissing();
      }
      ref.invalidate(avatarProvider);
      ref.invalidate(notificationsProvider);
      state = state.copyWith(
        status: AuthStatus.verified,
        needsProfile: needsProfile,
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
      dateOfBirth: dateOfBirth,
      clearError: true,
    );

    try {
      await ref
          .read(authRepositoryProvider)
          .requestEmailCode(
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

      // Create the patient profile (name + date of birth) now that the account has a session.
      final parts = (state.fullName ?? '').trim().split(RegExp(r'\s+'));
      final firstName = parts.first;
      final lastName = parts.length > 1 ? parts.skip(1).join(' ') : '';
      final dateOfBirth = state.dateOfBirth;
      var needsProfile = true;
      if (firstName.isNotEmpty && lastName.isNotEmpty && dateOfBirth != null) {
        try {
          await ref
              .read(profileRepositoryProvider)
              .saveProfile(
                firstName: firstName,
                lastName: lastName,
                dateOfBirth: dateOfBirth,
                country: ref.read(countryProvider).code,
              );
          needsProfile = false;
        } on ApiException {
          // Fall through: the app asks for the details again before going Home.
        }
      }
      await ref
          .read(sessionStoreProvider)
          .save(
            email: state.email,
            displayName: firstName.isNotEmpty
                ? firstName
                : _fallbackName(state.email),
            accessToken: ref.read(apiClientProvider).accessToken,
          );
      state = state.copyWith(needsProfile: needsProfile);
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
