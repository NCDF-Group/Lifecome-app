/// A bookable service (GP consultation, follow-up, ...), as the backend's service catalogue lists it.
class ClinicalService {
  const ClinicalService({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.fee,
    this.requiresAuthorisation = false,
  });

  final String id;

  /// Stable key, e.g. `gp-consultation` - what the app's cards map to.
  final String code;
  final String title;
  final String description;

  /// Price in naira (the backend stores kobo).
  final int fee;
  final bool requiresAuthorisation;

  factory ClinicalService.fromJson(Map<String, dynamic> json) =>
      ClinicalService(
        id: json['id'] as String,
        code: json['code'] as String,
        title: json['name'] as String,
        description: (json['description'] as String?) ?? '',
        fee: (json['basePriceKobo'] as int) ~/ 100,
      );
}
