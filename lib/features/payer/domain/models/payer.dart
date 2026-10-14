/// A health plan (HMO / insurer) taking part in LifeCome Live, from the
/// backend's `/payers`. The list arrives in the order the business wants it
/// shown, so nothing here re-sorts it.
class Payer {
  const Payer({
    required this.id,
    required this.code,
    required this.name,
    this.displayOrder = 100,
  });

  factory Payer.fromJson(Map<String, dynamic> json) => Payer(
    id: json['id'] as String,
    code: json['code'] as String? ?? '',
    name: (json['name'] as String? ?? '').trim(),
    displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 100,
  );

  final String id;

  /// The backend's stable code for the plan, sent when verifying a membership.
  final String code;
  final String name;
  final int displayOrder;
}
