import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
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
  const BookingOutcome({required this.appointment, this.payment});

  final Appointment appointment;

  /// The payment started for it, for a pay-per-visit booking.
  final PaymentTransaction? payment;

  bool get isConfirmed => appointment.status == BookingStatus.confirmed;
}

/// The idempotency keys for one attempt to book. Reuse the same ones when the
/// person taps "try again", so a retry can never book (or charge) twice.
class BookingAttemptKeys {
  const BookingAttemptKeys({
    required this.create,
    required this.payment,
    required this.confirm,
  });

  final String create;
  final String payment;
  final String confirm;
}

/// Turns a finished [BookingSelection] into a real appointment.
class BookingController {
  BookingController(this._ref);

  final Ref _ref;

  /// Creates the appointment (which holds the time), starts the payment for a
  /// pay-per-visit booking, then asks the backend to confirm it.
  ///
  /// The backend confirms a booking itself once the payment (or the health
  /// plan's authorisation) completes. Only test environments let the app
  /// confirm it directly, so a `PAYMENT_REQUIRED` answer is not an error: the
  /// appointment stays held and the outcome says so.
  Future<BookingOutcome> submit(
    BookingSelection selection,
    BookingAttemptKeys keys,
  ) async {
    final request = selection.toRequest();
    if (request == null) {
      throw const ApiException('Choose a service, clinician and time first.');
    }
    final repository = _ref.read(bookingRepositoryProvider);
    final appointments = _ref.read(appointmentsProvider.notifier);

    var appointment = await repository.createAppointment(
      request,
      idempotencyKey: keys.create,
      providerName: selection.doctor!.name,
      serviceName: selection.service!.name,
      slot: selection.slot!,
    );
    appointments.upsert(appointment);

    PaymentTransaction? payment;
    if (request.fundingRoute.apiValue == 'pay_per_visit') {
      payment = await repository.createPaymentIntent(
        appointment: appointment,
        idempotencyKey: keys.payment,
      );
    }

    try {
      appointment = await repository.confirmAppointment(
        appointment,
        idempotencyKey: keys.confirm,
      );
      appointments.upsert(appointment);
    } on ApiException catch (error) {
      if (error.code != 'PAYMENT_REQUIRED') rethrow;
    }

    return BookingOutcome(appointment: appointment, payment: payment);
  }
}

final bookingControllerProvider = Provider<BookingController>(
  BookingController.new,
);
