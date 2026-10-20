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

  /// Sign-up's last step — verifies the email code, then signs the account
  /// straight in. Reached with a [VerifyEmailArgs] passed as route `extra`.
  static const verifyEmail = '/verify-email';

  /// Kept as a source-compatible alias while older callers update.
  static const verifyMobile = verifyEmail;

  /// Shown once sign-up finishes. Reached with an [AuthSuccessArgs] passed
  /// as `extra`.
  static const signUpSuccess = '/sign-up-success';

  /// The step after sign-up where the person fills in their date of birth and
  /// the rest of their profile (the backend has none until they do).
  static const completeProfile = '/complete-profile';

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

  /// The notification centre, opened from the bell in the top bar.
  static const notifications = '/notifications';

  /// What to do in an emergency (999, NHS 111).
  static const emergency = '/emergency';

  /// GP services hub (screen pack 037): online or in-clinic GP, Menopause
  /// Care, and the person's GP care.
  static const gp = '/gp';

  /// "Before you book" (038) — who the visit is for, where they will be,
  /// and that it is not an emergency. Reached with a `BookingStart` whose
  /// `mode` was chosen on the GP hub.
  static const gpEligibility = '/gp/eligibility';

  /// Wellbeing hub (screen pack 091) and its screens (092-104). Sessions
  /// run on in-session preview data until they have a backend.
  static const wellbeing = '/wellbeing';

  /// One wellbeing offer, with a `WellbeingOffer` passed as `extra`.
  static const wellbeingOffer = '/wellbeing/offer';

  /// The practitioner, with a `WellbeingOffer` passed as `extra`.
  static const wellbeingPractitioner = '/wellbeing/practitioner';

  /// Choose a time, with a `WellbeingOffer` (book) or nothing (reschedule
  /// the booked session) passed as `extra`.
  static const wellbeingSlots = '/wellbeing/slots';

  /// Review, with a `WellbeingBookingDraft` passed as `extra`.
  static const wellbeingReview = '/wellbeing/review';
  static const wellbeingConfirmed = '/wellbeing/confirmed';
  static const wellbeingSession = '/wellbeing/session';
  static const wellbeingCancel = '/wellbeing/cancel';
  static const wellbeingCall = '/wellbeing/call';
  static const wellbeingPlan = '/wellbeing/plan';
  static const wellbeingCheckIn = '/wellbeing/check-in';

  /// Insurance hub (screen pack 117) and its screens (118-141). Linking a
  /// plan and checking cover use the real payer flow; enquiries, claims and
  /// support are in-session preview data.
  static const insurance = '/insurance';
  static const insuranceProducts = '/insurance/products';

  /// One category, with an `InsuranceCategory` passed as `extra`.
  static const insuranceProduct = '/insurance/product';

  /// The enquiry, with an `InsuranceCategory` passed as `extra`.
  static const insuranceEnquiry = '/insurance/enquiry';

  /// The finished enquiry, with an `InsuranceEnquiry` passed as `extra`.
  static const insuranceEnquirySent = '/insurance/enquiry-sent';
  static const insurancePolicies = '/insurance/policies';

  /// A linked plan, with a `LinkedPlan` passed as `extra`.
  static const insurancePolicy = '/insurance/policy';

  /// A linked plan's documents, with a `LinkedPlan` passed as `extra`.
  static const insuranceDocuments = '/insurance/documents';

  /// One document, with an `InsuranceDocument` passed as `extra`.
  static const insuranceDocument = '/insurance/document';
  static const insuranceCover = '/insurance/cover';
  static const insuranceClaims = '/insurance/claims';
  static const insuranceClaimStart = '/insurance/claim-start';

  /// A claim enquiry, with a `ClaimEnquiry` passed as `extra`.
  static const insuranceClaim = '/insurance/claim';
  static const insuranceClaimSent = '/insurance/claim-sent';
  static const insuranceSupport = '/insurance/support';

  /// The support enquiry, with an `InsuranceSupportEnquiry` as `extra`.
  static const insuranceSupportSent = '/insurance/support-sent';

  /// Wellbeing Shop (screen pack 105-116). Preview data until it has a
  /// backend.
  static const shop = '/shop';

  /// One product, with a `ShopProduct` passed as `extra`.
  static const shopProduct = '/shop/product';
  static const shopBasket = '/shop/basket';
  static const shopDelivery = '/shop/delivery';
  static const shopPayment = '/shop/payment';
  static const shopReview = '/shop/review';

  /// The placed order, with a `ShopOrder` passed as `extra`.
  static const shopConfirmed = '/shop/confirmed';
  static const shopOrders = '/shop/orders';

  /// Order screens below take a `ShopOrder` as `extra`.
  static const shopOrder = '/shop/order';
  static const shopTracking = '/shop/tracking';
  static const shopReturn = '/shop/return';

  /// The return request, with a `ShopReturnRequest` passed as `extra`.
  static const shopReturnSent = '/shop/return-sent';

  /// Professional Care hub (screen pack 069) and its screens (070-090).
  /// Care runs on in-session preview data until it has a backend.
  static const care = '/care';
  static const careServices = '/care/services';

  /// One care service, with a `CareService` passed as `extra`.
  static const careService = '/care/service';
  static const careRequest = '/care/request';
  static const careSubmitted = '/care/submitted';
  static const careStatus = '/care/status';
  static const careAssessment = '/care/assessment';
  static const careProposal = '/care/proposal';
  static const careAgreement = '/care/agreement';
  static const carePlan = '/care/plan';
  static const careVisits = '/care/visits';

  /// One visit, with a `CareVisit` passed as `extra`.
  static const careVisit = '/care/visit';
  static const careVisitNote = '/care/visit-note';
  static const careTeam = '/care/team';
  static const careChange = '/care/change';
  static const careChangeSent = '/care/change-sent';

  /// Menopause Care hub (062), under GP.
  static const menopause = '/gp/menopause';

  /// Menopause assessment (063-065): topic, history, then review.
  static const menopauseAssessment = '/gp/menopause/assessment';

  /// Online or in-clinic menopause consultation (066).
  static const menopauseBooking = '/gp/menopause/booking';

  /// The menopause care plan (067).
  static const menopausePlan = '/gp/menopause/plan';

  /// Review check-in before another menopause appointment (068).
  static const menopauseReview = '/gp/menopause/review';

  /// My Visits tab — upcoming/past appointments and their sub-flows.
  static const visits = '/visits';

  /// Messages tab — the single LifeCome care team conversation.
  static const messages = '/messages';

  /// One conversation with the care team; the thread's id follows it
  /// (`/message-thread/<id>`).
  static const messageThread = '/message-thread';

  /// Start a conversation with the care team: pick a topic and write to them.
  static const newMessage = '/message-new';

  /// Profile tab — account, health records, and support.
  static const profile = '/profile';

  static const healthRecords = '/profile/health-records';

  /// One kind of record (notes, prescriptions, referrals, results), with a
  /// `RecordKind` passed as `extra`.
  static const healthRecordsList = '/profile/health-records/list';

  /// Record details, each with its model passed as `extra`.
  static const clinicalNote = '/profile/health-records/note';
  static const prescription = '/profile/health-records/prescription';
  static const referral = '/profile/health-records/referral';
  static const diagnosticResult = '/profile/health-records/result';

  static const helpAndSupport = '/profile/help';

  /// Conditions, medicines and allergies the person chooses to note (screen
  /// pack 021). Kept on the device until the backend can store it.
  static const healthProfile = '/profile/health-profile';

  /// How the person pays for care (027).
  static const paymentMethods = '/profile/payment-methods';

  /// Which updates the person wants (029) — not the notification centre.
  static const notificationSettings = '/profile/notification-settings';

  /// Text size and motion (036).
  static const accessibility = '/profile/accessibility';

  static const editProfile = '/profile/edit';

  /// Who can access the patient's records and why — distinct from
  /// [privacyPolicy], the legal document it links out to.
  static const privacyAndSharing = '/profile/privacy-sharing';

  static const privacyPolicy = '/profile/privacy';

  static const termsAndConditions = '/profile/terms';

  /// Household plan, members and payment — distinct from [myBenefits],
  /// which is what that plan actually covers.
  static const membershipBilling = '/profile/membership-billing';

  /// What the patient's current plan covers and how to use it.
  static const myBenefits = '/profile/my-benefits';

  /// The plan picker (Individual / Adult household / existing member),
  /// reached from [membershipBilling]'s "Manage membership" button.
  static const membershipPlans = '/profile/membership-plans';

  /// Change, cancel or get help with a just-booked appointment. Reached
  /// with the appointment's `BookingSelection` passed as `extra`.
  static const manageAppointment = '/booking/manage-appointment';

  /// Search for an in-person Smart GP clinic. Reached from the Visit tab.
  static const findSmartGpClinic = '/visits/find-clinic';

  /// "Activate your access" — enter an employer/scheme invitation code (or
  /// a personal membership code) to link funding to the account. Reached
  /// from [chooseAccess]'s "Employer access" row.
  static const activateAccess = '/payer/activate-access';

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

  /// "Check your appointment" — a checklist hub reached after confirming a
  /// booking, fanning out to the clinical-suitability questions
  /// ([bookingBeforeYourVisit]) and the funding check ([linkHealthPlan]).
  /// Reached with a `BookingSelection`.
  static const appointmentCheck = '/booking/check-appointment';

  /// Blueprint view 14 — Before Your Visit (the clinical suitability
  /// questions). Reached with a `BookingSelection`.
  static const bookingBeforeYourVisit = '/booking/before-your-visit';

  /// "Choose your access" — how the patient wants to pay for or access
  /// care (pay per visit, membership, employer access, or a linked health
  /// plan), reached from My Visits' "Book a consultation".
  static const chooseAccess = '/booking/choose-access';

  /// "Link your health plan" — confirm cover with an HMO or LifeCome
  /// Benefits before booking. Reached with an optional HMO/provider name
  /// passed as `extra`.
  static const linkHealthPlan = '/payer/link-health-plan';

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

  /// "Let's get you connected" (screen pack 144), from the waiting room.
  static const connectionHelp = '/consultation/connection-help';

  /// "Your session has ended" (screen pack 149), shown when the backend
  /// stops accepting the saved sign-in.
  static const sessionEnded = '/session-ended';

  /// Blueprint view 20 — Care Plan & Visit Summary. Optionally reached with
  /// a `BookingSelection` passed as `extra` (a just-finished visit); with
  /// none, shows the empty state instead.
  static const careplan = '/care-plan';
}
