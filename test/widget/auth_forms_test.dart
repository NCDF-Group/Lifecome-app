import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:lifecome_mobile/core/providers/core_providers.dart';
import 'package:lifecome_mobile/core/router/route_paths.dart';
import 'package:lifecome_mobile/core/storage/secure_storage.dart';
import 'package:lifecome_mobile/features/auth/data/auth_repository.dart';
import 'package:lifecome_mobile/features/auth/presentation/create_account_screen.dart';
import 'package:lifecome_mobile/features/auth/presentation/forgot_password_screen.dart';
import 'package:lifecome_mobile/features/auth/presentation/new_password_screen.dart';
import 'package:lifecome_mobile/features/auth/presentation/password_changed_screen.dart';
import 'package:lifecome_mobile/features/auth/presentation/reset_password_screen.dart';
import 'package:lifecome_mobile/features/auth/presentation/sign_in_screen.dart';
import 'package:lifecome_mobile/features/auth/presentation/verify_mobile_screen.dart';
import 'package:lifecome_mobile/features/legal/presentation/privacy_screen.dart';
import 'package:lifecome_mobile/features/legal/presentation/terms_screen.dart';
import 'package:lifecome_mobile/features/welcome/presentation/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_auth_repository.dart';
import '../helpers/pump_app.dart';
import '../helpers/test_fonts.dart';

void main() {
  setUpAll(loadManrope);

  late FakeAuthRepository auth;
  late List<Override> overrides;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    auth = FakeAuthRepository();
    overrides = [
      authRepositoryProvider.overrideWithValue(auth),
      tokenStoreProvider.overrideWithValue(MemoryTokenStore()),
    ];
  });

  Finder field(int index) => find.byType(TextField).at(index);

  /// Taps a link inside a paragraph of text (a `TextSpan` with a recognizer).
  Future<void> tapLink(WidgetTester tester, String text) async {
    TextSpan? link;
    for (final element in find.byType(RichText).evaluate()) {
      (element.widget as RichText).text.visitChildren((span) {
        if (span is TextSpan && span.text == text) link = span;
        return link == null;
      });
      if (link != null) break;
    }
    expect(link, isNotNull, reason: 'no link says "$text"');
    (link!.recognizer! as TapGestureRecognizer).onTap!();
    await settle(tester);
  }

  group('sign in', () {
    testWidgets('has a back button that returns to the welcome screen', (
      tester,
    ) async {
      await pumpAppAt(tester, RoutePaths.welcome, overrides: overrides);
      await tapText(tester, 'Log in');
      expect(find.byType(SignInScreen), findsOneWidget);

      await tapBack(tester);
      expect(find.byType(SignInScreen), findsNothing);
      expect(find.byType(WelcomeScreen), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('an empty form says what is missing and sends nothing', (
      tester,
    ) async {
      await pumpAppAt(tester, RoutePaths.signIn, overrides: overrides);

      await tapText(tester, 'Sign in');

      expect(find.text('Enter your email address.'), findsOneWidget);
      expect(find.text('Enter your password.'), findsOneWidget);
      expect(auth.calls, isEmpty);

      await disposeApp(tester);
    });

    testWidgets('a malformed email is explained, then clears once fixed', (
      tester,
    ) async {
      await pumpAppAt(tester, RoutePaths.signIn, overrides: overrides);

      await tester.enterText(field(0), 'alex@');
      await tester.enterText(field(1), 'whatever');
      await tapText(tester, 'Sign in');
      expect(find.text('Enter a valid email address.'), findsOneWidget);
      expect(auth.calls, isEmpty);

      await tester.enterText(field(0), 'alex@example.com');
      await tester.pump();
      expect(find.text('Enter a valid email address.'), findsNothing);

      await disposeApp(tester);
    });

    testWidgets('valid details are sent to the backend, trimmed', (
      tester,
    ) async {
      auth.failure = const AuthException(
        'Email or password is incorrect.',
        code: 'INVALID_CREDENTIALS',
      );
      await pumpAppAt(tester, RoutePaths.signIn, overrides: overrides);

      await tester.enterText(field(0), '  alex@example.com ');
      await tester.enterText(field(1), 'Sunny-Day9');
      await tapText(tester, 'Sign in');

      expect(auth.calls, ['signIn:alex@example.com']);
      // The backend's own message reaches the person.
      expect(find.text('Email or password is incorrect.'), findsOneWidget);

      await disposeApp(tester);
    });
  });

  group('create account', () {
    Future<void> fillValidForm(WidgetTester tester) async {
      await tester.enterText(field(0), 'Alex');
      await tester.enterText(field(1), 'Morgan');
      await tester.enterText(field(2), 'alex@example.com');
      await tester.enterText(field(3), '07700 900123');
      await tester.enterText(field(4), 'Sunny-Day9');
      await tester.enterText(field(5), 'Sunny-Day9');
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
    }

    testWidgets('an empty form lists every problem and sends nothing', (
      tester,
    ) async {
      await pumpAppAt(tester, RoutePaths.createAccount, overrides: overrides);

      await tapText(tester, 'Create account');

      expect(find.text('Enter your first name.'), findsOneWidget);
      expect(find.text('Enter your last name.'), findsOneWidget);
      expect(find.text('Enter your email address.'), findsOneWidget);
      expect(find.text('Enter your mobile number.'), findsOneWidget);
      expect(find.text('Enter a password.'), findsOneWidget);
      expect(find.text('Confirm your password.'), findsOneWidget);
      expect(find.text('You must agree to the terms of use.'), findsOneWidget);
      expect(auth.calls, isEmpty);

      await disposeApp(tester);
    });

    testWidgets('names the password rule that is not met', (tester) async {
      await pumpAppAt(tester, RoutePaths.createAccount, overrides: overrides);
      await fillValidForm(tester);

      await tester.enterText(field(4), 'password1');
      await tester.enterText(field(5), 'password2');
      await tapText(tester, 'Create account');

      expect(
        find.text(
          'Include an uppercase letter, a lowercase letter, a number and a symbol.',
        ),
        findsOneWidget,
      );
      expect(find.text('Passwords do not match.'), findsOneWidget);
      expect(auth.calls, isEmpty);

      await disposeApp(tester);
    });

    testWidgets('rejects a landline and accepts a mobile', (tester) async {
      await pumpAppAt(tester, RoutePaths.createAccount, overrides: overrides);
      await fillValidForm(tester);

      await tester.enterText(field(3), '020 7946 0958');
      await tapText(tester, 'Create account');
      expect(
        find.text('Enter a valid UK mobile number, like 7700 900123.'),
        findsOneWidget,
      );
      expect(auth.calls, isEmpty);

      await tester.enterText(field(3), '07700 900123');
      await tester.pump();
      expect(
        find.text('Enter a valid UK mobile number, like 7700 900123.'),
        findsNothing,
      );

      await disposeApp(tester);
    });

    testWidgets('a pasted +44 or leading 0 never doubles up', (tester) async {
      await pumpAppAt(tester, RoutePaths.createAccount, overrides: overrides);
      await fillValidForm(tester);

      await tester.enterText(field(3), '+447700900123');
      await tapText(tester, 'Create account');

      expect(auth.calls, [
        'register:Alex Morgan:alex@example.com:+447700900123',
      ]);

      await disposeApp(tester);
    });

    testWidgets('valid details register and move to verification', (
      tester,
    ) async {
      await pumpAppAt(tester, RoutePaths.createAccount, overrides: overrides);
      await fillValidForm(tester);

      await tapText(tester, 'Create account');

      expect(auth.calls, [
        'register:Alex Morgan:alex@example.com:+447700900123',
      ]);
      expect(find.byType(VerifyMobileScreen), findsOneWidget);
      expect(
        find.textContaining('+44 •••• ••0123', findRichText: true),
        findsOneWidget,
      );

      await disposeApp(tester);
    });

    testWidgets('the backend\'s field complaints land under the right field', (
      tester,
    ) async {
      auth.failure = const AuthException(
        'Check the details you entered.',
        code: 'VALIDATION_FAILED',
        fieldErrors: {'phoneNumber': 'That mobile number is already in use.'},
      );
      await pumpAppAt(tester, RoutePaths.createAccount, overrides: overrides);
      await fillValidForm(tester);

      await tapText(tester, 'Create account');

      expect(
        find.text('That mobile number is already in use.'),
        findsOneWidget,
      );
      expect(find.byType(CreateAccountScreen), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('the verification step asks for all six digits, and back '
        'returns to the form', (tester) async {
      await pumpAppAt(tester, RoutePaths.createAccount, overrides: overrides);
      await fillValidForm(tester);
      await tapText(tester, 'Create account');
      expect(find.byType(VerifyMobileScreen), findsOneWidget);

      await tapText(tester, 'Verify and continue');
      expect(find.text('Enter the 6-digit code.'), findsOneWidget);
      expect(auth.calls.where((c) => c.startsWith('verifyPhoneCode')), isEmpty);

      await tapBack(tester);
      expect(find.byType(VerifyMobileScreen), findsNothing);
      expect(find.byType(CreateAccountScreen), findsOneWidget);

      await disposeApp(tester);
    });
  });

  group('forgot password', () {
    testWidgets('asks for a code (not a link) and checks the email', (
      tester,
    ) async {
      await pumpAppAt(tester, RoutePaths.forgotPassword, overrides: overrides);

      expect(find.textContaining('6-digit code'), findsOneWidget);
      expect(find.text('Send reset code'), findsOneWidget);

      await tapText(tester, 'Send reset code');
      expect(find.text('Enter your email address.'), findsOneWidget);

      await tester.enterText(field(0), 'not-an-email');
      await tapText(tester, 'Send reset code');
      expect(find.text('Enter a valid email address.'), findsOneWidget);
      expect(auth.calls, isEmpty);

      await disposeApp(tester);
    });

    testWidgets('back works even with nothing behind it', (tester) async {
      await pumpAppAt(tester, RoutePaths.forgotPassword, overrides: overrides);

      await tapBack(tester);
      expect(find.byType(ForgotPasswordScreen), findsNothing);
      expect(find.byType(SignInScreen), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('walks through code and new password, validating each', (
      tester,
    ) async {
      await pumpAppAt(tester, RoutePaths.forgotPassword, overrides: overrides);

      await tester.enterText(field(0), 'alex@example.com');
      await tapText(tester, 'Send reset code');
      expect(auth.calls, ['requestPasswordReset:alex@example.com']);
      expect(find.byType(ResetPasswordScreen), findsOneWidget);

      // Nothing typed yet.
      await tapText(tester, 'Verify code');
      expect(find.text('Enter the 6-digit code.'), findsOneWidget);

      // Back returns to the email step.
      await tapBack(tester);
      expect(find.byType(ForgotPasswordScreen), findsOneWidget);
      await tapText(tester, 'Send reset code');
      expect(find.byType(ResetPasswordScreen), findsOneWidget);

      // Typing all six digits submits the code.
      for (var i = 0; i < 6; i++) {
        await tester.enterText(field(i), '${i + 1}');
      }
      await settle(tester);
      expect(
        auth.calls.last,
        'verifyPasswordResetCode:alex@example.com:123456',
      );
      expect(find.byType(NewPasswordScreen), findsOneWidget);

      // A weak password, then a mismatch, then a good one.
      await tapText(tester, 'Reset password');
      expect(find.text('Enter a password.'), findsOneWidget);
      expect(find.text('Confirm your password.'), findsOneWidget);

      await tester.enterText(field(0), 'short');
      await tester.enterText(field(1), 'short');
      await tapText(tester, 'Reset password');
      expect(find.text('Use at least 8 characters.'), findsOneWidget);

      await tester.enterText(field(0), 'Sunny-Day9');
      await tester.enterText(field(1), 'Sunny-Day8');
      await tapText(tester, 'Reset password');
      expect(find.text('Passwords do not match.'), findsOneWidget);
      expect(auth.calls.any((c) => c.startsWith('setNewPassword')), isFalse);

      await tester.enterText(field(1), 'Sunny-Day9');
      await tapText(tester, 'Reset password');
      expect(auth.calls.last, 'setNewPassword:alex@example.com:123456');
      expect(find.byType(PasswordChangedScreen), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('a wrong code shows the backend\'s message and clears the '
        'boxes', (tester) async {
      await pumpAppAt(tester, RoutePaths.forgotPassword, overrides: overrides);
      await tester.enterText(field(0), 'alex@example.com');
      await tapText(tester, 'Send reset code');

      auth.failure = const AuthException(
        'That code is not correct.',
        code: 'OTP_INCORRECT',
      );
      for (var i = 0; i < 6; i++) {
        await tester.enterText(field(i), '${i + 1}');
      }
      await settle(tester);

      expect(find.text('That code is not correct.'), findsOneWidget);
      expect(find.byType(ResetPasswordScreen), findsOneWidget);

      await disposeApp(tester);
    });
  });

  group('policies', () {
    testWidgets('sign up opens the real terms and privacy notice', (
      tester,
    ) async {
      await pumpAppAt(tester, RoutePaths.createAccount, overrides: overrides);

      await tapLink(tester, 'Terms of use');
      expect(find.byType(TermsScreen), findsOneWidget);
      expect(find.text('Coming soon'), findsNothing);
      await tapBack(tester);
      expect(find.byType(CreateAccountScreen), findsOneWidget);

      await tapLink(tester, 'Privacy notice');
      expect(find.byType(PrivacyScreen), findsOneWidget);
      await tapBack(tester);
      expect(find.byType(CreateAccountScreen), findsOneWidget);

      await disposeApp(tester);
    });

    testWidgets('sign in opens the real privacy notice', (tester) async {
      await pumpAppAt(tester, RoutePaths.signIn, overrides: overrides);

      await tapLink(tester, 'Privacy notice');
      expect(find.byType(PrivacyScreen), findsOneWidget);
      await tapBack(tester);
      expect(find.byType(SignInScreen), findsOneWidget);

      await disposeApp(tester);
    });
  });
}
