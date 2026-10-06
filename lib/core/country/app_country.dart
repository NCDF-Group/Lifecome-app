import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The countries LifeCome Live serves. The user's country decides the flag
/// and name shown on the home screen.
enum AppCountry {
  nigeria(code: 'NG', flag: '🇳🇬', name: 'Nigeria', dialCode: '+234'),
  unitedKingdom(code: 'GB', flag: '🇬🇧', name: 'UK', dialCode: '+44');

  const AppCountry({
    required this.code,
    required this.flag,
    required this.name,
    required this.dialCode,
  });

  /// ISO 3166-1 alpha-2 code, used as the stored value.
  final String code;
  final String flag;
  final String name;
  final String dialCode;

  static AppCountry? fromCode(String? code) {
    for (final country in values) {
      if (country.code == code) return country;
    }
    return null;
  }

  /// The country a full phone number (e.g. `+447700900123`) belongs to.
  static AppCountry? fromPhoneNumber(String phoneNumber) {
    for (final country in values) {
      if (phoneNumber.startsWith(country.dialCode)) return country;
    }
    return null;
  }
}

/// The user's country, remembered between launches. Defaults to Nigeria
/// until the user picks one (on the home screen, or implicitly through
/// their phone number at sign-up).
class CountryController extends Notifier<AppCountry> {
  static const _key = 'app_country';

  @override
  AppCountry build() {
    SharedPreferences.getInstance().then((prefs) {
      final saved = AppCountry.fromCode(prefs.getString(_key));
      if (saved != null && ref.mounted) state = saved;
    });
    return AppCountry.nigeria;
  }

  Future<void> select(AppCountry country) async {
    state = country;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, country.code);
  }
}

final countryProvider = NotifierProvider<CountryController, AppCountry>(
  CountryController.new,
);
