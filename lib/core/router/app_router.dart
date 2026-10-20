import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/care/domain/care_models.dart';
import '../../features/care/presentation/care_hub_screens.dart';
import '../../features/care/presentation/care_journey_screens.dart';
import '../../features/care/presentation/care_request_screen.dart';
import '../../features/care/presentation/care_visits_screens.dart';
import '../../features/profile/presentation/accessibility_screen.dart';
import '../../features/profile/presentation/health_profile_screen.dart';
import '../../features/profile/presentation/notification_settings_screen.dart';
import '../../features/profile/presentation/payment_methods_screen.dart';
import '../../features/health_records/domain/models/clinical_note.dart';
import '../../features/health_records/domain/models/diagnostic_result.dart';
import '../../features/health_records/domain/models/prescription.dart';
import '../../features/health_records/domain/models/referral.dart';
import '../../features/health_records/presentation/diagnostic_result_screen.dart';
import '../../features/health_records/presentation/prescription_detail_screen.dart';
import '../../features/health_records/presentation/record_detail_screen.dart';
import '../../features/health_records/presentation/records_list_screen.dart';
import '../../features/health_records/presentation/referral_detail_screen.dart';
import '../../features/menopause/presentation/menopause_assessment_screen.dart';
import '../../features/menopause/presentation/menopause_booking_screen.dart';
import '../../features/menopause/presentation/menopause_hub_screen.dart';
import '../../features/menopause/presentation/menopause_plan_screen.dart';
import '../../features/menopause/presentation/menopause_review_screen.dart';
import '../../features/gp/presentation/gp_eligibility_screen.dart';
import '../../features/gp/presentation/gp_hub_screen.dart';
import '../../features/auth/presentation/app_lock_screen.dart';
import '../../features/auth/presentation/create_account_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/new_password_screen.dart';
import '../../features/auth/presentation/password_changed_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/auth/presentation/sign_up_success_screen.dart';
import '../../features/auth/presentation/verify_mobile_screen.dart';
import '../../features/booking/application/booking_controller.dart';
import '../../features/booking/domain/models/appointment.dart';
import '../../features/booking/domain/models/booking_selection.dart';
import '../../features/booking/presentation/appointment_check_screen.dart';
import '../../features/booking/presentation/before_your_visit_screen.dart';
import '../../features/booking/presentation/booking_confirmation_screen.dart';
import '../../features/booking/presentation/booking_location_screen.dart';
import '../../features/booking/presentation/choose_access_screen.dart';
import '../../features/booking/presentation/choose_appointment_time_screen.dart';
import '../../features/booking/presentation/choose_service_screen.dart';
import '../../features/booking/presentation/find_smart_gp_clinic_screen.dart';
import '../../features/booking/presentation/manage_appointment_screen.dart';
import '../../features/booking/presentation/my_visits_screen.dart';
import '../../features/booking/presentation/review_booking_screen.dart';
import '../../features/care_plan/presentation/care_plan_screen.dart';
import '../../features/consultation/presentation/consultation_call_screen.dart';
import '../../features/consultation/presentation/waiting_room_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/emergency/presentation/emergency_guidance_screen.dart';
import '../../features/doctors/presentation/doctor_profile_screen.dart';
import '../../features/doctors/presentation/find_a_doctor_screen.dart';
import '../../features/health_records/presentation/health_records_screen.dart';
import '../../features/legal/presentation/privacy_screen.dart';
import '../../features/legal/presentation/terms_screen.dart';
import '../../features/membership/presentation/membership_billing_screen.dart';
import '../../features/membership/presentation/membership_plans_screen.dart';
import '../../features/membership/presentation/my_benefits_screen.dart';
import '../../features/messaging/domain/models/message_thread.dart';
import '../../features/messaging/presentation/message_threads_screen.dart';
import '../../features/messaging/presentation/new_message_screen.dart';
import '../../features/messaging/presentation/thread_detail_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/payer/domain/models/membership.dart';
import '../../features/payer/domain/models/payer.dart';
import '../../features/payer/presentation/activate_access_screen.dart';
import '../../features/payer/presentation/hmo_coverage_screen.dart';
import '../../features/payer/presentation/link_health_plan_screen.dart';
import '../../features/payer/presentation/select_hmo_screen.dart';
import '../../features/payer/presentation/verify_hmo_membership_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/patient_profile_screen.dart';
import '../../features/profile/presentation/privacy_sharing_screen.dart';
import '../../features/services/domain/models/wellbeing_service.dart';
import '../../features/services/presentation/services_screen.dart';
import '../../features/services/presentation/wellbeing_service_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/support/presentation/help_centre_screen.dart';
import '../../features/welcome/presentation/welcome_screen.dart';
import 'app_shell.dart';
import 'route_paths.dart';

/// A redirect for a screen that is opened with an object passed as `extra`
/// (a booking in progress, an appointment): if it arrives without one —
/// restored after the app was closed, or opened from a link — send the person
/// to [fallback] instead of crashing on the missing object.
GoRouterRedirect _requires<T extends Object>(String fallback) {
  return (context, state) => state.extra is T ? null : fallback;
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RoutePaths.splash,
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: RoutePaths.appLock,
        builder: (context, state) => const AppLockScreen(),
      ),
      GoRoute(
        path: RoutePaths.signIn,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: RoutePaths.createAccount,
        builder: (context, state) => const CreateAccountScreen(),
      ),
      GoRoute(
        path: RoutePaths.verifyEmail,
        builder: (context, state) =>
            VerifyEmailScreen(args: state.extra! as VerifyEmailArgs),
      ),
      GoRoute(
        path: RoutePaths.signUpSuccess,
        builder: (context, state) => const SignUpSuccessScreen(),
      ),
      GoRoute(
        path: RoutePaths.completeProfile,
        builder: (context, state) => const EditProfileScreen(onboarding: true),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RoutePaths.resetPassword,
        builder: (context, state) =>
            ResetPasswordScreen(args: state.extra! as ResetPasswordArgs),
      ),
      GoRoute(
        path: RoutePaths.newPassword,
        builder: (context, state) =>
            NewPasswordScreen(args: state.extra! as NewPasswordArgs),
      ),
      GoRoute(
        path: RoutePaths.passwordChanged,
        builder: (context, state) => const PasswordChangedScreen(),
      ),
      GoRoute(
        path: '${RoutePaths.messageThread}/:id',
        builder: (context, state) =>
            ThreadDetailScreen(threadId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: RoutePaths.newMessage,
        builder: (context, state) =>
            NewMessageScreen(initialTopic: state.extra as MessageTopic?),
      ),
      GoRoute(
        path: RoutePaths.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: RoutePaths.activateAccess,
        builder: (context, state) => ActivateAccessScreen(
          initial: state.extra is AccessKind
              ? state.extra! as AccessKind
              : AccessKind.employer,
        ),
      ),
      GoRoute(
        path: RoutePaths.payerSelectHmo,
        builder: (context, state) => const SelectHmoScreen(),
      ),
      GoRoute(
        path: RoutePaths.payerVerifyMembership,
        redirect: _requires<Payer>(RoutePaths.payerSelectHmo),
        builder: (context, state) =>
            VerifyHmoMembershipScreen(payer: state.extra! as Payer),
      ),
      GoRoute(
        path: RoutePaths.payerCoverage,
        redirect: _requires<LinkedPlan>(RoutePaths.chooseAccess),
        builder: (context, state) =>
            HmoCoverageScreen(plan: state.extra! as LinkedPlan),
      ),
      GoRoute(
        path: RoutePaths.linkHealthPlan,
        builder: (context, state) =>
            LinkHealthPlanScreen(payer: state.extra as Payer?),
      ),
      GoRoute(
        path: RoutePaths.chooseAccess,
        builder: (context, state) => const ChooseAccessScreen(),
      ),
      GoRoute(
        path: RoutePaths.bookingChooseService,
        redirect: _requires<BookingStart>(RoutePaths.chooseAccess),
        builder: (context, state) =>
            ChooseServiceScreen(start: state.extra! as BookingStart),
      ),
      GoRoute(
        path: RoutePaths.bookingLocation,
        redirect: _requires<BookingSelection>(RoutePaths.chooseAccess),
        builder: (context, state) =>
            BookingLocationScreen(selection: state.extra! as BookingSelection),
      ),
      GoRoute(
        path: RoutePaths.wellbeingService,
        builder: (context, state) =>
            WellbeingServiceScreen(service: state.extra! as WellbeingService),
      ),
      GoRoute(
        path: RoutePaths.doctorsFindADoctor,
        redirect: _requires<BookingSelection>(RoutePaths.chooseAccess),
        builder: (context, state) =>
            FindADoctorScreen(selection: state.extra! as BookingSelection),
      ),
      GoRoute(
        path: RoutePaths.doctorsProfile,
        redirect: _requires<BookingSelection>(RoutePaths.chooseAccess),
        builder: (context, state) =>
            DoctorProfileScreen(selection: state.extra! as BookingSelection),
      ),
      GoRoute(
        path: RoutePaths.bookingAppointmentTime,
        redirect: _requires<BookingSelection>(RoutePaths.chooseAccess),
        builder: (context, state) => ChooseAppointmentTimeScreen(
          selection: state.extra! as BookingSelection,
        ),
      ),
      GoRoute(
        path: RoutePaths.appointmentCheck,
        redirect: _requires<Appointment>(RoutePaths.visits),
        builder: (context, state) =>
            AppointmentCheckScreen(appointment: state.extra! as Appointment),
      ),
      GoRoute(
        path: RoutePaths.bookingBeforeYourVisit,
        redirect: _requires<BookingSelection>(RoutePaths.chooseAccess),
        builder: (context, state) =>
            BeforeYourVisitScreen(selection: state.extra! as BookingSelection),
      ),
      GoRoute(
        path: RoutePaths.bookingReview,
        redirect: _requires<BookingSelection>(RoutePaths.chooseAccess),
        builder: (context, state) =>
            ReviewBookingScreen(selection: state.extra! as BookingSelection),
      ),
      GoRoute(
        path: RoutePaths.bookingConfirmation,
        redirect: _requires<BookingOutcome>(RoutePaths.visits),
        builder: (context, state) =>
            BookingConfirmationScreen(outcome: state.extra! as BookingOutcome),
      ),
      GoRoute(
        path: RoutePaths.manageAppointment,
        redirect: _requires<Appointment>(RoutePaths.visits),
        builder: (context, state) =>
            ManageAppointmentScreen(appointment: state.extra! as Appointment),
      ),
      GoRoute(
        path: RoutePaths.findSmartGpClinic,
        builder: (context, state) =>
            FindSmartGpClinicScreen(start: state.extra as BookingStart?),
      ),
      GoRoute(
        path: RoutePaths.consultationWaitingRoom,
        redirect: _requires<Appointment>(RoutePaths.visits),
        builder: (context, state) =>
            WaitingRoomScreen(appointment: state.extra! as Appointment),
      ),
      GoRoute(
        path: RoutePaths.consultationCall,
        redirect: _requires<Appointment>(RoutePaths.visits),
        builder: (context, state) =>
            ConsultationCallScreen(appointment: state.extra! as Appointment),
      ),
      GoRoute(
        path: RoutePaths.careplan,
        builder: (context, state) =>
            CarePlanScreen(appointment: state.extra as Appointment?),
      ),
      // No longer a tab: Home's four service cards replaced it. Kept as a
      // pushed screen until the Wellbeing hub takes over its content.
      GoRoute(
        path: RoutePaths.services,
        builder: (context, state) => const ServicesScreen(),
      ),
      GoRoute(
        path: RoutePaths.gp,
        builder: (context, state) => const GpHubScreen(),
      ),
      GoRoute(
        path: RoutePaths.gpEligibility,
        redirect: _requires<BookingStart>(RoutePaths.gp),
        builder: (context, state) =>
            GpEligibilityScreen(start: state.extra! as BookingStart),
      ),
      GoRoute(
        path: RoutePaths.care,
        builder: (context, state) => const CareHubScreen(),
      ),
      GoRoute(
        path: RoutePaths.careServices,
        builder: (context, state) => const CareServicesScreen(),
      ),
      GoRoute(
        path: RoutePaths.careService,
        redirect: _requires<CareService>(RoutePaths.careServices),
        builder: (context, state) =>
            CareServiceScreen(service: state.extra! as CareService),
      ),
      GoRoute(
        path: RoutePaths.careRequest,
        builder: (context, state) =>
            CareRequestScreen(service: state.extra as CareService?),
      ),
      GoRoute(
        path: RoutePaths.careSubmitted,
        builder: (context, state) => const CareSubmittedScreen(),
      ),
      GoRoute(
        path: RoutePaths.careStatus,
        builder: (context, state) => const CareStatusScreen(),
      ),
      GoRoute(
        path: RoutePaths.careAssessment,
        builder: (context, state) => const CareAssessmentScreen(),
      ),
      GoRoute(
        path: RoutePaths.careProposal,
        builder: (context, state) => const CareProposalScreen(),
      ),
      GoRoute(
        path: RoutePaths.careAgreement,
        builder: (context, state) => const CareAgreementScreen(),
      ),
      GoRoute(
        path: RoutePaths.carePlan,
        builder: (context, state) => const CarePlanDetailScreen(),
      ),
      GoRoute(
        path: RoutePaths.careVisits,
        builder: (context, state) => const CareVisitsScreen(),
      ),
      GoRoute(
        path: RoutePaths.careVisit,
        redirect: _requires<CareVisit>(RoutePaths.careVisits),
        builder: (context, state) =>
            CareVisitScreen(visit: state.extra! as CareVisit),
      ),
      GoRoute(
        path: RoutePaths.careVisitNote,
        builder: (context, state) => const CareVisitNoteScreen(),
      ),
      GoRoute(
        path: RoutePaths.careTeam,
        builder: (context, state) => const CareTeamScreen(),
      ),
      GoRoute(
        path: RoutePaths.careChange,
        builder: (context, state) => const CareChangeScreen(),
      ),
      GoRoute(
        path: RoutePaths.careChangeSent,
        builder: (context, state) => const CareChangeSentScreen(),
      ),
      GoRoute(
        path: RoutePaths.menopause,
        builder: (context, state) => const MenopauseHubScreen(),
      ),
      GoRoute(
        path: RoutePaths.menopauseAssessment,
        builder: (context, state) => const MenopauseAssessmentScreen(),
      ),
      GoRoute(
        path: RoutePaths.menopauseBooking,
        builder: (context, state) => const MenopauseBookingScreen(),
      ),
      GoRoute(
        path: RoutePaths.menopausePlan,
        builder: (context, state) => const MenopausePlanScreen(),
      ),
      GoRoute(
        path: RoutePaths.menopauseReview,
        builder: (context, state) => const MenopauseReviewScreen(),
      ),
      GoRoute(
        path: RoutePaths.emergency,
        builder: (context, state) => const EmergencyGuidanceScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.home,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.visits,
                builder: (context, state) => const MyVisitsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.messages,
                builder: (context, state) => const MessageThreadsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.profile,
                builder: (context, state) => const PatientProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'health-records',
                    builder: (context, state) => const HealthRecordsScreen(),
                    routes: [
                      GoRoute(
                        path: 'list',
                        redirect: _requires<RecordKind>(
                          RoutePaths.healthRecords,
                        ),
                        builder: (context, state) =>
                            RecordsListScreen(kind: state.extra! as RecordKind),
                      ),
                      GoRoute(
                        path: 'note',
                        redirect: _requires<ClinicalNote>(
                          RoutePaths.healthRecords,
                        ),
                        builder: (context, state) => RecordDetailScreen(
                          note: state.extra! as ClinicalNote,
                        ),
                      ),
                      GoRoute(
                        path: 'prescription',
                        redirect: _requires<Prescription>(
                          RoutePaths.healthRecords,
                        ),
                        builder: (context, state) => PrescriptionDetailScreen(
                          prescription: state.extra! as Prescription,
                        ),
                      ),
                      GoRoute(
                        path: 'referral',
                        redirect: _requires<Referral>(RoutePaths.healthRecords),
                        builder: (context, state) => ReferralDetailScreen(
                          referral: state.extra! as Referral,
                        ),
                      ),
                      GoRoute(
                        path: 'result',
                        redirect: _requires<DiagnosticResult>(
                          RoutePaths.healthRecords,
                        ),
                        builder: (context, state) => DiagnosticResultScreen(
                          result: state.extra! as DiagnosticResult,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'health-profile',
                    builder: (context, state) => const HealthProfileScreen(),
                  ),
                  GoRoute(
                    path: 'payment-methods',
                    builder: (context, state) => const PaymentMethodsScreen(),
                  ),
                  GoRoute(
                    path: 'notification-settings',
                    builder: (context, state) =>
                        const NotificationSettingsScreen(),
                  ),
                  GoRoute(
                    path: 'accessibility',
                    builder: (context, state) => const AccessibilityScreen(),
                  ),
                  GoRoute(
                    path: 'help',
                    builder: (context, state) => const HelpCentreScreen(),
                  ),
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) => const EditProfileScreen(),
                  ),
                  GoRoute(
                    path: 'privacy-sharing',
                    builder: (context, state) => const PrivacySharingScreen(),
                  ),
                  GoRoute(
                    path: 'membership-billing',
                    builder: (context, state) =>
                        const MembershipBillingScreen(),
                  ),
                  GoRoute(
                    path: 'my-benefits',
                    builder: (context, state) => const MyBenefitsScreen(),
                  ),
                  GoRoute(
                    path: 'membership-plans',
                    builder: (context, state) => const MembershipPlansScreen(),
                  ),
                  GoRoute(
                    path: 'privacy',
                    builder: (context, state) => const PrivacyScreen(),
                  ),
                  GoRoute(
                    path: 'terms',
                    builder: (context, state) => const TermsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
