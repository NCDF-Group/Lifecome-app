import '../../../../core/utils/formatters.dart';

/// Where a health plan's approval of a visit is. The backend's
/// `authorisation_status`.
enum AuthorisationStatus {
  notRequired('not_required', 'Not needed'),
  pending('pending', 'Waiting for your plan'),
  approved('approved', 'Approved'),
  declined('declined', 'Declined'),
  expired('expired', 'Expired'),
  moreInfoRequired('more_info_required', 'More information needed');

  const AuthorisationStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static AuthorisationStatus parse(Object? value) {
    for (final status in values) {
      if (status.apiValue == value) return status;
    }
    return pending;
  }
}

/// A health plan's pre-authorisation for a visit (`POST /authorisations`).
class Authorisation {
  const Authorisation({
    required this.id,
    required this.status,
    this.payerReference,
    this.infoRequested,
    this.decidedAt,
  });

  factory Authorisation.fromJson(Map<String, dynamic> json) => Authorisation(
    id: json['id'] as String,
    status: AuthorisationStatus.parse(json['status']),
    payerReference: json['payerReference'] as String?,
    infoRequested: json['infoRequested'] as String?,
    decidedAt: Formatters.parseInstant(json['decidedAt']),
  );

  final String id;
  final AuthorisationStatus status;
  final String? payerReference;

  /// What the plan wants to know, when [status] is `moreInfoRequired`.
  final String? infoRequested;
  final DateTime? decidedAt;
}
