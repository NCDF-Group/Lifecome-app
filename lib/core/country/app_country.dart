import 'package:flutter_riverpod/flutter_riverpod.dart';

/// LifeCome Live serves the UK only. Kept as a single-value type (rather
/// than a bare constant) so the handful of call sites that display a flag,
/// name or dial code don't need special-casing.
enum AppCountry {
  unitedKingdom(code: 'GB', flag: '🇬🇧', name: 'UK', dialCode: '+44');

  const AppCountry({
    required this.code,
    required this.flag,
    required this.name,
    required this.dialCode,
  });

  /// ISO 3166-1 alpha-2 code.
  final String code;
  final String flag;
  final String name;
  final String dialCode;
}

/// Always the UK — there is no country picker since there is nothing to
/// pick between.
final countryProvider = Provider<AppCountry>((ref) => AppCountry.unitedKingdom);
