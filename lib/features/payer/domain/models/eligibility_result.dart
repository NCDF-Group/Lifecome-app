import '../../../../core/utils/formatters.dart';
import 'eligibility_status.dart';

/// The answer to "does this membership cover this service?"
/// (`POST /eligibility/check`).
class EligibilityCheck {
  const EligibilityCheck({
    required this.id,
    required this.membershipId,
    required this.status,
    this.coPayMinor,
    this.checkedAt,
  });

  factory EligibilityCheck.fromJson(Map<String, dynamic> json) {
    // The backend stores the co-pay as text in the smallest currency unit.
    final coPay = json['coPayKobo'];
    return EligibilityCheck(
      id: json['id'] as String,
      membershipId: json['membershipId'] as String? ?? '',
      status: EligibilityStatus.parse(json['status']),
      coPayMinor: coPay is num ? coPay.toInt() : int.tryParse('$coPay'),
      checkedAt: Formatters.parseInstant(json['checkedAt']),
    );
  }

  final String id;
  final String membershipId;
  final EligibilityStatus status;

  /// What the person pays themselves, in pence, when [status] is `coPay`.
  final int? coPayMinor;
  final DateTime? checkedAt;
}
