import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/app_lock_screen.dart';
import '../../features/auth/presentation/create_account_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/new_password_screen.dart';
import '../../features/auth/presentation/password_changed_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/auth/presentation/sign_up_success_screen.dart';
import '../../features/auth/presentation/verify_mobile_screen.dart';
import '../../features/booking/domain/models/appointment.dart';
import '../../features/booking/presentation/before_your_visit_screen.dart';
import '../../features/booking/presentation/booking_confirmation_screen.dart';
import '../../features/booking/presentation/booking_location_screen.dart';
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
import '../../features/doctors/presentation/doctor_profile_screen.dart';
import '../../features/doctors/presentation/find_a_doctor_screen.dart';
import '../../features/health_records/presentation/health_records_screen.dart';
import '../../features/legal/presentation/privacy_screen.dart';
import '../../features/legal/presentation/terms_screen.dart';
import '../../features/membership/presentation/membership_billing_screen.dart';
import '../../features/membership/presentation/membership_plans_screen.dart';
import '../../features/membership/presentation/my_benefits_screen.dart';
import '../../features/messaging/presentation/message_threads_screen.dart';
import '../../features/payer/presentation/hmo_coverage_screen.dart';
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
        path: RoutePaths.verifyMobile,
        builder: (context, state) =>
            VerifyMobileScreen(args: state.extra! as VerifyMobileArgs),
      ),
      GoRoute(
        path: RoutePaths.signUpSuccess,
        builder: (context, state) => const SignUpSuccessScreen(),
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
        path: RoutePaths.payerSelectHmo,
        builder: (context, state) => const SelectHmoScreen(),
      ),
      GoRoute(
        path: RoutePaths.payerVerifyMembership,
        builder: (context, state) =>
            VerifyHmoMembershipScreen(hmoName: state.extra! as String),
      ),
      GoRoute(
        path: RoutePaths.payerCoverage,
        builder: (context, state) =>
            HmoCoverageScreen(hmoName: state.extra! as String),
      ),
      GoRoute(
        path: RoutePaths.bookingChooseService,
        builder: (context, state) {
          final args = state.extra! as (BookingAccessType, String?);
          return ChooseServiceScreen(accessType: args.$1, hmoName: args.$2);
        },
      ),
      GoRoute(
        path: RoutePaths.bookingLocation,
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
        builder: (context, state) =>
            FindADoctorScreen(selection: state.extra! as BookingSelection),
      ),
      GoRoute(
        path: RoutePaths.doctorsProfile,
        builder: (context, state) =>
            DoctorProfileScreen(selection: state.extra! as BookingSelection),
      ),
      GoRoute(
        path: RoutePaths.bookingAppointmentTime,
        builder: (context, state) => ChooseAppointmentTimeScreen(
          selection: state.extra! as BookingSelection,
        ),
      ),
      GoRoute(
        path: RoutePaths.bookingBeforeYourVisit,
        builder: (context, state) =>
            BeforeYourVisitScreen(selection: state.extra! as BookingSelection),
      ),
      GoRoute(
        path: RoutePaths.bookingReview,
        builder: (context, state) =>
            ReviewBookingScreen(selection: state.extra! as BookingSelection),
      ),
      GoRoute(
        path: RoutePaths.bookingConfirmation,
        builder: (context, state) => BookingConfirmationScreen(
          selection: state.extra! as BookingSelection,
        ),
      ),
      GoRoute(
        path: RoutePaths.manageAppointment,
        builder: (context, state) => ManageAppointmentScreen(
          selection: state.extra! as BookingSelection,
        ),
      ),
      GoRoute(
        path: RoutePaths.findSmartGpClinic,
        builder: (context, state) => const FindSmartGpClinicScreen(),
      ),
      GoRoute(
        path: RoutePaths.consultationWaitingRoom,
        builder: (context, state) =>
            WaitingRoomScreen(selection: state.extra! as BookingSelection),
      ),
      GoRoute(
        path: RoutePaths.consultationCall,
        builder: (context, state) =>
            ConsultationCallScreen(selection: state.extra! as BookingSelection),
      ),
      GoRoute(
        path: RoutePaths.careplan,
        builder: (context, state) =>
            CarePlanScreen(selection: state.extra as BookingSelection?),
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
                path: RoutePaths.services,
                builder: (context, state) => const ServicesScreen(),
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
