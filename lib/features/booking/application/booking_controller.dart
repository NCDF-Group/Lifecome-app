import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../payer/application/payer_controller.dart';
import '../../payer/domain/models/authorisation.dart';
import '../../payer/domain/models/eligibility_result.dart';
import '../../payer/domain/models/eligibility_status.dart';
import '../../payment/domain/models/payment_transaction.dart';
import '../data/booking_repository.dart';
import '../domain/models/appointment.dart';
import '../domain/models/availability_slot.dart';
import '../domain/models/booking_selection.dart';
import '../domain/models/booking_status.dart';
import '../domain/models/clinical_service.dart';

/// The booking repository the screens depend on. Overridden in tests.
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return DioBookingRepository(ref.watch(apiClientProvider));
});

/// The services that can be booked.
final clinicalServicesProvider = FutureProvider<List<ClinicalService>>((ref) {
  ref.watch(sessionEpochProvider);
  return ref.watch(bookingRepositoryProvider).listServices();
});

/// The times one clinician can still be booked, soonest first. Looked up when
/// a clinician's card is on screen and dropped when it is not.
final availabilityProvider = FutureProvider.autoDispose
    .family<List<AvailabilitySlot>, String>((ref, providerId) {
      ref.watch(sessionEpochProvider);
      return ref.watch(bookingRepositoryProvider).listAvailability(providerId);
    });

/// The signed-in person's appointments. Starts over whenever someone signs in
/// or out, so one person's visits are never shown to the next.
class AppointmentsNotifier extends AsyncNotifier<List<Appointment>> {
  @override
  Future<List<Appointment>> build() {
    ref.watch(sessionEpochProvider);
    return ref.watch(bookingRepositoryProvider).listAppointments();
  }

  /// Loads the list again, keeping what is on screen until the answer arrives.
  Future<void> refresh() async {
    final repository = ref.read(bookingRepositoryProvider);
    state = await AsyncValue.guard(repository.listAppointments);
  }

  /// Puts a new or changed appointment into the list straight away.
  void upsert(Appointment appointment) {
    final current = state.value;
    if (current == null) return;
    final index = current.indexWhere((item) => item.id == appointment.id);
    state = AsyncData([
      if (index == -1) appointment,
      for (var i = 0; i < current.length; i++)
        i == index ? appointment : current[i],
    ]);
  }

  /// Cancels an appointment. Throws an `ApiException` if the backend refuses.
  Future<Appointment> cancel(Appointment appointment) async {
    final cancelled = await ref
        .read(bookingRepositoryProvider)
        .cancelAppointment(appointment);
    upsert(cancelled);
    return cancelled;
  }
}

final appointmentsProvider =
    AsyncNotifierProvider<AppointmentsNotifier, List<Appointment>>(
      AppointmentsNotifier.new,
    );

/// Upcoming appointments, soonest first.
final upcomingAppointmentsProvider = Provider<AsyncValue<List<Appointment>>>((
  ref,
) {
  return ref.watch(appointmentsProvider).whenData((all) {
    final now = DateTime.now();
    return [
      for (final item in all)
        if (item.isUpcoming(now: now)) item,
    ]..sort((a, b) => a.startsAt.compareTo(b.startsAt));
  });
});

/// Everything that is no longer upcoming, most recent first.
final pastAppointmentsProvider = Provider<AsyncValue<List<Appointment>>>((ref) {
  return ref.watch(appointmentsProvider).whenData((all) {
    final now = DateTime.now();
    return [
      for (final item in all)
        if (!item.isUpcoming(now: now)) item,
    ]..sort((a, b) => b.startsAt.compareTo(a.startsAt));
  });
});

/// What booking an appointment came to.
class BookingOutcome {
  const BookingOutcome({
    required this.appointment,
    this.payment,
    this.planName,
    this.eligibility,
    this.authorisation,
  });

  final Appointment appointment;

  /// The payment started for it, for a pay-per-visit booking.
  final PaymentTransaction? payment;

  /// The health plan paying for it, for a plan-funded booking.
  final String? planName;

  /// What the plan said about covering the service.
  final EligibilityCheck? eligibility;

  /// The plan's approval of the visit, when it needed one.
  final Authorisation? authorisation;

  bool get isConfirmed => appointment.status == BookingStatus.confirmed;
}

/// The idempotency keys for one attempt to book. Reuse the same ones when the
/// person taps "try again", so a retry can never book (or charge) twice.
class BookingAttemptKeys {
  const BookingAttemptKeys({
    required this.create,
    required this.payment,
    required this.confirm,
    required this.authorisation,
  });

  final String create;
  final String payment;
  final String confirm;
  final String authorisation;
}

/// Turns a finished [BookingSelection] into a real appointment.
class BookingController {
  BookingController(this._ref);

  final Ref _ref;

  /// Creates the appointment (which holds the time), then pays for or gets
  /// approval of it, then asks the backend to confirm it:
  ///
  /// * Pay per visit: starts the payment.
  /// * Health plan: asks the plan about cover first (nothing is booked if the
  ///   service is not covered) and, if the plan wants to approve each visit,
  ///   asks for that.
  ///
  /// The backend confirms a booking itself once the payment (or the plan's
  /// authorisation) completes. Only test environments let the app confirm it
  /// directly, so a `PAYMENT_REQUIRED` answer is not an error: the appointment
  /// stays held and the outcome says so.
  Future<BookingOutcome> submit(
    BookingSelection selection,
    BookingAttemptKeys keys,
  ) async {
    final request = selection.toRequest();
    if (request == null) {
      throw const ApiException('Choose a service, clinician and time first.');
    }
    final repository = _ref.read(bookingRepositoryProvider);
    final payers = _ref.read(payerRepositoryProvider);
    final appointments = _ref.read(appointmentsProvider.notifier);
    final service = selection.service!;
    final plan = selection.plan;

    // A plan-funded booking starts by asking the plan: if it will not cover
    // the service, nothing is booked and no time is held.
    EligibilityCheck? eligibility;
    if (plan != null) {
      eligibility = await payers.checkEligibility(
        membershipId: plan.membership.id,
        clinicalServiceCode: service.code,
      );
      if (!eligibility.status.isBookable) {
        throw ApiException(
          _notCoveredMessage(eligibility.status, plan.name),
          code: 'NOT_COVERED',
        );
      }
    }

    var appointment = await repository.createAppointment(
      request,
      idempotencyKey: keys.create,
      providerName: selection.doctor!.name,
      serviceName: service.name,
      slot: selection.slot!,
    );
    appointments.upsert(appointment);

    PaymentTransaction? payment;
    Authorisation? authorisation;
    if (plan == null) {
      payment = await repository.createPaymentIntent(
        appointment: appointment,
        idempotencyKey: keys.payment,
      );
    } else if (eligibility!.status ==
        EligibilityStatus.preAuthorisationRequired) {
      authorisation = await payers.requestAuthorisation(
        eligibilityCheckId: eligibility.id,
        clinicalServiceCode: service.code,
        providerId: selection.doctor!.id,
        appointmentId: appointment.id,
        idempotencyKey: keys.authorisation,
      );
    }

    // Only ask for confirmation when nothing is still outstanding.
    final outstanding =
        authorisation != null &&
        authorisation.status != AuthorisationStatus.approved;
    if (!outstanding) {
      try {
        appointment = await repository.confirmAppointment(
          appointment,
          idempotencyKey: keys.confirm,
        );
        appointments.upsert(appointment);
      } on ApiException catch (error) {
        if (error.code != 'PAYMENT_REQUIRED') rethrow;
      }
    }

    return BookingOutcome(
      appointment: appointment,
      payment: payment,
      planName: plan?.name,
      eligibility: eligibility,
      authorisation: authorisation,
    );
  }

  String _notCoveredMessage(EligibilityStatus status, String plan) =>
      switch (status) {
        EligibilityStatus.excluded =>
          "$plan doesn't cover this service. Choose another service, or pay "
              'for it yourself.',
        EligibilityStatus.benefitLimitReached =>
          "You've used all of your $plan benefit for this service.",
        _ =>
          "We couldn't check your cover with $plan just now. Please try again "
              'in a few minutes.',
      };
}

final bookingControllerProvider = Provider<BookingController>(
  BookingController.new,
);
