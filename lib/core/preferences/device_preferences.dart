import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// On/off settings kept on this device (accessibility and notification
/// choices). The backend has nowhere to store them yet. Each starts at its
/// default and is replaced by the saved value once read.
class DevicePreferences extends Notifier<Map<String, bool>> {
  static const _prefix = 'pref_';

  static const defaults = <String, bool>{
    largerText: false,
    reduceMotion: false,
    appointmentReminders: true,
    teamMessages: true,
    orderUpdates: true,
    policyUpdates: true,
  };

  static const largerText = 'larger_text';
  static const reduceMotion = 'reduce_motion';
  static const appointmentReminders = 'appointment_reminders';
  static const teamMessages = 'team_messages';
  static const orderUpdates = 'order_updates';
  static const policyUpdates = 'policy_updates';

  @override
  Map<String, bool> build() {
    _load();
    return defaults;
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = {
        for (final key in defaults.keys)
          key: prefs.getBool('$_prefix$key') ?? defaults[key]!,
      };
    } catch (_) {
      // Unreadable preferences just stay at their defaults.
    }
  }

  Future<void> set(String key, bool value) async {
    state = {...state, key: value};
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('$_prefix$key', value);
    } catch (_) {
      // Applied for this session even if it can't be saved.
    }
  }
}

final devicePreferencesProvider =
    NotifierProvider<DevicePreferences, Map<String, bool>>(
      DevicePreferences.new,
    );
