import '../../../../core/utils/formatters.dart';
import 'payer.dart';

/// A membership the backend has verified for the signed-in person
/// (`POST /payers/verify-membership`).
class Membership {
  const Membership({
    required this.id,
    required this.payerId,
    required this.memberId,
    this.planId,
    this.verifiedAt,
  });

  factory Membership.fromJson(Map<String, dynamic> json) => Membership(
    id: json['id'] as String,
    payerId: json['payerId'] as String? ?? '',
    memberId: json['memberId'] as String? ?? '',
    planId: (json['planId'] as String?)?.trim().isEmpty ?? true
        ? null
        : (json['planId'] as String).trim(),
    verifiedAt: Formatters.parseInstant(json['verifiedAt']),
  );

  final String id;
  final String payerId;

  /// The number on the person's membership card.
  final String memberId;

  /// The plan the payer says they are on, if it said.
  final String? planId;
  final DateTime? verifiedAt;
}

/// A verified membership together with the health plan it is with.
class LinkedPlan {
  const LinkedPlan({required this.payer, required this.membership});

  final Payer payer;
  final Membership membership;

  String get name => payer.name;
}
