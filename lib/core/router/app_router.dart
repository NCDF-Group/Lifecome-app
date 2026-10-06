import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/app_lock_screen.dart';
import '../../features/auth/presentation/create_account_screen.dart';
import '../../features/auth/presentation/create_password_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/new_password_screen.dart';
import '../../features/auth/presentation/password_changed_screen.dart';
import '../../features/auth/presentation/personal_details_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/auth/presentation/sign_up_success_screen.dart';
import '../../features/auth/presentation/verify_email_screen.dart';
import '../../features/booking/domain/models/appointment.dart';
import '../../features/booking/presentation/before_your_visit_screen.dart';
import '../../features/booking/presentation/booking_confirmation_screen.dart';
import '../../features/booking/presentation/choose_appointment_time_screen.dart';
import '../../features/booking/domain/models/access_option.dart';
import '../../features/booking/presentation/choose_access_screen.dart';
import '../../features/booking/presentation/choose_service_screen.dart';
import '../../features/booking/presentation/connect_access_screen.dart';
import '../../features/booking/presentation/my_benefits_screen.dart';
import '../../features/booking/presentation/my_visits_screen.dart';
import '../../features/booking/presentation/review_booking_screen.dart';
import '../../features/booking/presentation/smart_gp_locations_screen.dart';
import '../../features/care_plan/presentation/care_plan_screen.dart';
import '../../features/care_plan/presentation/next_steps_screen.dart';
import '../../features/consultation/presentation/consultation_call_screen.dart';
import '../../features/consultation/presentation/waiting_room_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/doctors/presentation/doctor_profile_screen.dart';
import '../../features/doctors/presentation/find_a_doctor_screen.dart';
import '../../features/health_records/presentation/health_records_screen.dart';
import '../../features/legal/presentation/privacy_screen.dart';
import '../../features/legal/presentation/terms_screen.dart';
import '../../features/messaging/presentation/message_threads_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/payer/presentation/choose_payment_method_screen.dart';
import '../../features/payer/presentation/hmo_coverage_screen.dart';
import '../../features/payer/presentation/select_hmo_screen.dart';
import '../../features/payer/presentation/verify_hmo_membership_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/patient_profile_screen.dart';
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
        path: RoutePaths.personalDetails,
        builder: (context, state) =>
            PersonalDetailsScreen(args: state.extra! as PersonalDetailsArgs),
      ),
      GoRoute(
        path: RoutePaths.verifyEmail,
        builder: (context, state) =>
            VerifyEmailScreen(args: state.extra! as VerifyEmailArgs),
      ),
      GoRoute(
        path: RoutePaths.createPassword,
        builder: (context, state) => const CreatePasswordScreen(),
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
        path: RoutePaths.payerChoosePaymentMethod,
        builder: (context, state) => const ChoosePaymentMethodScreen(),
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
        path: RoutePaths.visits,
        builder: (context, state) => const MyVisitsScreen(),
      ),
      GoRoute(
        path: RoutePaths.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      StatefulShellRoute(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        navigatorContainerBuilder: (context, navigationShell, children) =>
            FadingBranches(
              currentIndex: navigationShell.currentIndex,
              children: children,
            ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.home,
                builder: (context, state) => const DashboardScreen(),
                routes: [
                  GoRoute(
                    path: 'next-steps',
                    builder: (context, state) => const NextStepsScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.book,
                builder: (context, state) => const ChooseAccessScreen(),
                routes: [
                  GoRoute(
                    path: 'connect',
                    builder: (context, state) => ConnectAccessScreen(
                      initial:
                          state.extra as AccessOption? ??
                          AccessOption.lifecomeBenefits,
                    ),
                  ),
                  GoRoute(
                    path: 'benefits',
                    builder: (context, state) => const MyBenefitsScreen(),
                  ),
                  GoRoute(
                    path: 'help',
                    builder: (context, state) {
                      final args = state.extra! as (BookingAccessType, String?);
                      return ChooseServiceScreen(
                        accessType: args.$1,
                        hmoName: args.$2,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'doctor',
                    builder: (context, state) => DoctorProfileScreen(
                      selection: state.extra! as BookingSelection,
                    ),
                  ),
                  GoRoute(
                    path: 'time',
                    builder: (context, state) => ChooseAppointmentTimeScreen(
                      selection: state.extra! as BookingSelection,
                    ),
                  ),
                  GoRoute(
                    path: 'prepare',
                    builder: (context, state) => BeforeYourVisitScreen(
                      selection: state.extra! as BookingSelection,
                    ),
                  ),
                  GoRoute(
                    path: 'review',
                    builder: (context, state) => ReviewBookingScreen(
                      selection: state.extra! as BookingSelection,
                    ),
                  ),
                  GoRoute(
                    path: 'confirmation',
                    builder: (context, state) => BookingConfirmationScreen(
                      selection: state.extra! as BookingSelection,
                    ),
                  ),
                  GoRoute(
                    path: 'locations',
                    builder: (context, state) => SmartGpLocationsScreen(
                      selection: state.extra! as BookingSelection,
                    ),
                  ),
                  GoRoute(
                    path: 'find-gp',
                    builder: (context, state) => FindADoctorScreen(
                      selection: state.extra! as BookingSelection,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.healthRecords,
                builder: (context, state) => const HealthRecordsScreen(),
                routes: [
                  GoRoute(
                    path: 'care-plan',
                    builder: (context, state) => CarePlanScreen(
                      selection: state.extra as BookingSelection?,
                    ),
                  ),
                ],
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
                    path: 'help',
                    builder: (context, state) => const HelpCentreScreen(),
                  ),
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) => const EditProfileScreen(),
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
