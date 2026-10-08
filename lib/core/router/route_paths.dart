/// Named route paths, kept in one place so a screen is never linked to by a
/// hand-typed string in more than one file.
abstract final class RoutePaths {
  static const splash = '/';

  /// The single static welcome screen shown after the splash screen when
  /// there is no remembered session. No "seen it before" flag is persisted
  /// (would need local storage beyond the session flag), so it shows on
  /// every cold launch that isn't already signed in.
  static const welcome = '/welcome';

  /// Shown instead of [welcome] when a session was remembered from a
  /// previous launch (see `SessionStore`). Reached with an [AppLockArgs]
  /// passed as `extra`.
  static const appLock = '/app-lock';

  static const signIn = '/sign-in';

  /// One page: name, email, mobile number and password together.
  static const createAccount = '/create-account';

  /// Sign-up's last step — verifies the SMS code sent to the mobile number
  /// collected on [createAccount], then signs the account straight in.
  /// Reached with a [VerifyMobileArgs] passed as the route's `extra`.
  static const verifyMobile = '/verify-mobile';

  /// Shown once sign-up finishes. Reached with an [AuthSuccessArgs] passed
  /// as `extra`.
  static const signUpSuccess = '/sign-up-success';

  /// Step 1 of the forgot-password flow: enter the account email.
  static const forgotPassword = '/forgot-password';

  /// Step 2: enter the reset code sent to that email. Reached with a
  /// [ResetPasswordArgs] passed as `extra`.
  static const resetPassword = '/reset-password';

  /// Step 3: choose a new password. Reached with a [NewPasswordArgs]
  /// passed as `extra`.
  static const newPassword = '/new-password';

  /// Shown once the password reset finishes. Reached with an
  /// [AuthSuccessArgs] passed as `extra`.
  static const passwordChanged = '/password-changed';

  /// The LifeCome Live Dashboard (blueprint view 04) — the Home tab of the
  /// bottom-nav shell (see `AppShell`).
  static const home = '/home';

  /// Services tab — Explore our services (GP care + everyday wellbeing).
  static const services = '/services';

  /// A wellbeing service's detail page (see
  /// `lib/features/services/domain/models/wellbeing_service.dart`). Reached
  /// with a `WellbeingService` passed as `extra`.
  static const wellbeingService = '/services/wellbeing';

  /// My Visits tab — upcoming/past appointments and their sub-flows.
  static const visits = '/visits';

  /// Messages tab — the single LifeCome care team conversation.
  static const messages = '/messages';

  /// Profile tab — account, health records, and support.
  static const profile = '/profile';

  static const healthRecords = '/profile/health-records';

  static const helpAndSupport = '/profile/help';

  static const editProfile = '/profile/edit';

  static const privacyPolicy = '/profile/privacy';

  static const termsAndConditions = '/profile/terms';

  /// Blueprint view 06 — Select Your HMO. The entry point for the
  /// employer/HMO-covered path (Home and Services' "Employer access" link
  /// straight here) — "choose how to pay" no longer gates it; the direct-pay
  /// path reached from "Online GP"/"Clinic care" goes straight to
  /// [bookingChooseService] instead.
  static const payerSelectHmo = '/payer/select-hmo';

  /// Blueprint view 07 — Verify HMO Membership. Reached with the chosen
  /// HMO's name passed as `extra`.
  static const payerVerifyMembership = '/payer/verify-membership';

  /// Blueprint view 08 — HMO Coverage & Benefits. Reached with the verified
  /// HMO's name passed as `extra`.
  static const payerCoverage = '/payer/coverage';

  /// Blueprint views 09/10 — Check Service Eligibility (HMO) and Choose a
  /// Service (direct-pay); one screen serves both (see
  /// `ChooseServiceScreen`). Reached with a `BookingAccessType` + optional
  /// HMO name passed as `extra`.
  static const bookingChooseService = '/booking/choose-service';

  /// Between choosing a service and finding a doctor: confirms where the
  /// patient is, so availability can be shown for their area. Reached with
  /// a `BookingSelection`.
  static const bookingLocation = '/booking/location';

  /// Blueprint view 11 — Find a Doctor. Reached with a `BookingSelection`.
  static const doctorsFindADoctor = '/doctors/find';

  /// Blueprint view 12 — Doctor Profile. Reached with a `BookingSelection`.
  static const doctorsProfile = '/doctors/profile';

  /// Blueprint view 13 — Choose Appointment Time. Reached with a
  /// `BookingSelection`.
  static const bookingAppointmentTime = '/booking/appointment-time';

  /// Blueprint view 14 — Before Your Visit. Reached with a
  /// `BookingSelection`.
  static const bookingBeforeYourVisit = '/booking/before-your-visit';

  /// Blueprint views 15-16 — Review Booking & Payment / HMO Authorisation
  /// (merged into one screen). Reached with a `BookingSelection`.
  static const bookingReview = '/booking/review';

  /// Blueprint view 17 — Booking Confirmation. Reached with a
  /// `BookingSelection`.
  static const bookingConfirmation = '/booking/confirmation';

  /// Blueprint view 18 — Consultation Waiting Room. Reached with a
  /// `BookingSelection`.
  static const consultationWaitingRoom = '/consultation/waiting-room';

  /// Blueprint view 19 — Video / Audio Consultation. Reached with a
  /// `BookingSelection`.
  static const consultationCall = '/consultation/call';

  /// Blueprint view 20 — Care Plan & Visit Summary. Optionally reached with
  /// a `BookingSelection` passed as `extra` (a just-finished visit); with
  /// none, shows the empty state instead.
  static const careplan = '/care-plan';
}
