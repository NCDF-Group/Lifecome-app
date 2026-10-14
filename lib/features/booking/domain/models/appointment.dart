import 'booking_status.dart';
import 'consultation_mode.dart';

/// What the patient told the care team when booking ("Before your visit").
/// Every field is optional on the backend; `toJson` leaves out what is empty.
class AppointmentIntake {
  const AppointmentIntake({
    this.reason,
    this.medicinesAndAllergies,
    this.accessibilitySupport,
    this.callbackNumber,
    this.patientLocation,
    this.understoodRemoteLimits,
  });

  factory AppointmentIntake.fromJson(Map<String, dynamic> json) {
    String? text(Object? value) {
      final trimmed = (value as String?)?.trim();
      return trimmed == null || trimmed.isEmpty ? null : trimmed;
    }

    return AppointmentIntake(
      reason: text(json['reason']),
      medicinesAndAllergies: text(json['medicinesAndAllergies']),
      accessibilitySupport: text(json['accessibilitySupport']),
      callbackNumber: text(json['callbackNumber']),
      patientLocation: text(json['patientLocation']),
      understoodRemoteLimits: json['understoodRemoteLimits'] as bool?,
    );
  }

  final String? reason;
  final String? medicinesAndAllergies;
  final String? accessibilitySupport;

  /// The number the clinician rings if the call drops, or for a phone consult.
  final String? callbackNumber;

  /// Where the patient will be during an online consultation.
  final String? patientLocation;

  /// Ticked to say they understand an online consultation has limits.
  final bool? understoodRemoteLimits;

  Map<String, dynamic> toJson() => {
    'reason': ?reason,
    'medicinesAndAllergies': ?medicinesAndAllergies,
    'accessibilitySupport': ?accessibilitySupport,
    'callbackNumber': ?callbackNumber,
    'patientLocation': ?patientLocation,
    'understoodRemoteLimits': ?understoodRemoteLimits,
  };
}

/// One of the patient's appointments, as the backend returns it
/// (`/appointments`).
class Appointment {
  const Appointment({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.clinicalServiceId,
    required this.serviceName,
    required this.availabilitySlotId,
    required this.startsAt,
    required this.durationMinutes,
    required this.mode,
    required this.status,
    required this.fundingRoute,
    required this.createdAt,
    this.presentingConcern,
    this.locationCity,
    this.clinicName,
    this.intake,
    this.authorisationId,
  });

  /// Reads an appointment. A just-created appointment comes back without the
  /// clinician's name, the service name or the time (those come from joined
  /// tables on the list endpoint), so the caller can supply them.
  factory Appointment.fromJson(
    Map<String, dynamic> json, {
    String? providerName,
    String? serviceName,
    DateTime? startsAt,
    int? durationMinutes,
  }) {
    String? text(Object? value) {
      final trimmed = (value as String?)?.trim();
      return trimmed == null || trimmed.isEmpty ? null : trimmed;
    }

    final intake = json['intake'];
    final start = json['startsAt'] is String
        ? DateTime.parse(json['startsAt'] as String).toUtc()
        : startsAt;
    return Appointment(
      id: json['id'] as String,
      providerId: json['providerId'] as String,
      providerName: (json['providerName'] as String?) ?? providerName ?? '',
      clinicalServiceId: json['clinicalServiceId'] as String,
      serviceName: (json['serviceName'] as String?) ?? serviceName ?? '',
      availabilitySlotId: json['availabilitySlotId'] as String,
      startsAt: start ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      durationMinutes:
          (json['durationMinutes'] as num?)?.toInt() ?? durationMinutes ?? 30,
      mode:
          ConsultationMode.parse(json['consultationMode']) ??
          ConsultationMode.video,
      status: BookingStatus.parse(json['status']),
      fundingRoute: FundingRoute.parse(json['fundingRoute']),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '')?.toUtc() ??
          DateTime.now().toUtc(),
      presentingConcern: text(json['presentingConcern']),
      locationCity: text(json['locationCity']),
      clinicName: text(json['clinicName']),
      intake: intake is Map<String, dynamic>
          ? AppointmentIntake.fromJson(intake)
          : null,
      authorisationId: text(json['authorisationId']),
    );
  }

  final String id;
  final String providerId;
  final String providerName;
  final String clinicalServiceId;
  final String serviceName;
  final String availabilitySlotId;

  /// When it starts, in UTC. Show it with `Formatters.appointmentWhen` and
  /// friends, which convert to UK time.
  final DateTime startsAt;
  final int durationMinutes;
  final ConsultationMode mode;
  final BookingStatus status;
  final FundingRoute fundingRoute;
  final DateTime createdAt;
  final String? presentingConcern;
  final String? locationCity;
  final String? clinicName;
  final AppointmentIntake? intake;
  final String? authorisationId;

  DateTime get endsAt => startsAt.add(Duration(minutes: durationMinutes));

  /// A short reference to quote to support: `LCL-` and the start of the id.
  String get reference =>
      'LCL-${id.replaceAll('-', '').substring(0, 8).toUpperCase()}';

  /// A held appointment whose ten-minute hold has run out without it ever
  /// being confirmed: the slot has gone back on sale.
  bool isHoldExpired({DateTime? now}) =>
      status == BookingStatus.slotHeld &&
      (now ?? DateTime.now()).toUtc().difference(createdAt) >
          const Duration(minutes: 10);

  /// Still ahead of the patient: confirmed (or just held) and not over yet.
  bool isUpcoming({DateTime? now}) {
    final moment = (now ?? DateTime.now()).toUtc();
    final live =
        status == BookingStatus.confirmed ||
        (status == BookingStatus.slotHeld && !isHoldExpired(now: moment));
    return live && endsAt.isAfter(moment);
  }

  Appointment copyWith({BookingStatus? status}) => Appointment(
    id: id,
    providerId: providerId,
    providerName: providerName,
    clinicalServiceId: clinicalServiceId,
    serviceName: serviceName,
    availabilitySlotId: availabilitySlotId,
    startsAt: startsAt,
    durationMinutes: durationMinutes,
    mode: mode,
    status: status ?? this.status,
    fundingRoute: fundingRoute,
    createdAt: createdAt,
    presentingConcern: presentingConcern,
    locationCity: locationCity,
    clinicName: clinicName,
    intake: intake,
    authorisationId: authorisationId,
  );
}

/// What it takes to create an appointment (`POST /appointments`). The patient
/// comes from the sign-in, never from the request.
class NewAppointment {
  const NewAppointment({
    required this.providerId,
    required this.clinicalServiceId,
    required this.availabilitySlotId,
    required this.mode,
    required this.fundingRoute,
    this.presentingConcern,
    this.locationCity,
    this.clinicName,
    this.intake,
  });

  final String providerId;
  final String clinicalServiceId;
  final String availabilitySlotId;
  final ConsultationMode mode;
  final FundingRoute fundingRoute;
  final String? presentingConcern;
  final String? locationCity;
  final String? clinicName;
  final AppointmentIntake? intake;

  Map<String, dynamic> toJson() => {
    'providerId': providerId,
    'clinicalServiceId': clinicalServiceId,
    'availabilitySlotId': availabilitySlotId,
    'consultationMode': mode.apiValue,
    'fundingRoute': fundingRoute.apiValue,
    'presentingConcern': ?presentingConcern,
    'locationCity': ?locationCity,
    'clinicName': ?clinicName,
    if (intake != null && intake!.toJson().isNotEmpty)
      'intake': intake!.toJson(),
  };
}
