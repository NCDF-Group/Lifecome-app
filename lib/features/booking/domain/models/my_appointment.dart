/// One of the signed-in patient's appointments (`GET /appointments`).
class MyAppointment {
  const MyAppointment({
    required this.id,
    required this.status,
    required this.providerName,
    required this.serviceName,
    required this.startsAt,
    required this.consultationMode,
    this.locationCity,
    this.clinicName,
  });

  final String id;

  /// `slot_held`, `confirmed`, `cancelled`, `rescheduled`, `doctor_unavailable`, `patient_no_show`.
  final String status;
  final String providerName;
  final String serviceName;
  final DateTime startsAt;
  final String consultationMode;
  final String? locationCity;
  final String? clinicName;

  bool get isInPerson => consultationMode == 'in_person';
  bool get isCancelled => status == 'cancelled';
  bool get isUpcoming =>
      startsAt.isAfter(DateTime.now()) &&
      (status == 'confirmed' || status == 'slot_held');

  factory MyAppointment.fromJson(Map<String, dynamic> json) => MyAppointment(
    id: json['id'] as String,
    status: json['status'] as String,
    providerName: json['providerName'] as String,
    serviceName: json['serviceName'] as String,
    startsAt: DateTime.parse(json['startsAt'] as String).toUtc(),
    consultationMode: json['consultationMode'] as String,
    locationCity: json['locationCity'] as String?,
    clinicName: json['clinicName'] as String?,
  );
}
