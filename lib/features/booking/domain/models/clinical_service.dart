import '../../../../core/utils/formatters.dart';

/// A bookable service from the backend's catalogue (`/clinical-services`):
/// a GP consultation, a follow-up, a results review...
class ClinicalService {
  const ClinicalService({
    required this.id,
    required this.code,
    required this.name,
    required this.durationMinutes,
    required this.priceMinor,
    this.description,
  });

  factory ClinicalService.fromJson(Map<String, dynamic> json) {
    final description = (json['description'] as String?)?.trim();
    return ClinicalService(
      id: json['id'] as String,
      code: json['code'] as String? ?? '',
      name: (json['name'] as String? ?? '').trim(),
      description: description == null || description.isEmpty
          ? null
          : description,
      durationMinutes: (json['defaultDurationMinutes'] as num?)?.toInt() ?? 30,
      // The backend names the column after Nigeria's currency (`basePriceKobo`)
      // but the amount is in the smallest unit of whatever currency the
      // service is sold in; LifeCome Live UK sells in pounds.
      priceMinor: (json['basePriceKobo'] as num?)?.toInt() ?? 0,
    );
  }

  final String id;

  /// The backend's stable code for the service, used for eligibility checks.
  final String code;
  final String name;
  final String? description;
  final int durationMinutes;

  /// The price in pence.
  final int priceMinor;

  String get title => name;
  String get priceLabel => Formatters.money(priceMinor);
}
