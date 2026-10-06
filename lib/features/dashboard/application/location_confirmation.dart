import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Whether the user has confirmed the location suggested on Home. Until
/// they do, Home shows the "Suggested location - please confirm" block
/// above the services. Remembered between launches.
///
/// Starts `true` (block hidden) and flips to `false` only once the stored
/// flag has loaded and says it was never confirmed, so a returning user
/// doesn't see the block flash on every launch.
class LocationConfirmation extends Notifier<bool> {
  static const _key = 'location_confirmed';

  @override
  bool build() {
    SharedPreferences.getInstance().then((prefs) {
      final confirmed = prefs.getBool(_key) ?? false;
      if (ref.mounted) state = confirmed;
    });
    return true;
  }

  Future<void> confirm() async {
    state = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}

final locationConfirmationProvider =
    NotifierProvider<LocationConfirmation, bool>(LocationConfirmation.new);
