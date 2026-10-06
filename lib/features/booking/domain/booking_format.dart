import '../../../core/country/app_country.dart';

const _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// "Monday 12 October 2026".
String formatFullDate(DateTime date) =>
    '${_weekdays[date.weekday - 1]} ${date.day} ${_months[date.month - 1]} '
    '${date.year}';

/// "12 October 2026".
String formatShortDate(DateTime date) =>
    '${date.day} ${_months[date.month - 1]} ${date.year}';

/// The time zone appointment times are shown in.
String timeZoneFor(AppCountry country) => switch (country) {
  AppCountry.nigeria => 'Africa/Lagos',
  AppCountry.unitedKingdom => 'Europe/London',
};

/// A service fee (stored in naira) in the user's currency. There is no
/// pricing backend, so UK prices are a fixed 1:100 conversion.
String formatFee(AppCountry country, int nairaFee) => switch (country) {
  AppCountry.nigeria => '₦${_grouped(nairaFee)}',
  AppCountry.unitedKingdom => '£${_grouped(nairaFee ~/ 100)}',
};

String currencyCode(AppCountry country) =>
    country == AppCountry.unitedKingdom ? 'GBP' : 'NGN';

String _grouped(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// Wall-clock time in [country]'s appointment time zone for a UTC moment: Nigeria is UTC+1 all year,
/// the UK is UTC+0 (winter) or UTC+1 (summer time: last Sunday of March to last Sunday of October).
DateTime zonedTime(DateTime utc, AppCountry country) {
  final moment = utc.toUtc();
  final offset = switch (country) {
    AppCountry.nigeria => 1,
    AppCountry.unitedKingdom => _isUkSummerTime(moment) ? 1 : 0,
  };
  // A UTC-flagged DateTime whose clock fields read as the local wall time.
  return moment.add(Duration(hours: offset));
}

/// "09:00" - the wall-clock time of [utc] in [country]'s zone.
String formatClock(DateTime utc, AppCountry country) {
  final local = zonedTime(utc, country);
  return '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}

bool _isUkSummerTime(DateTime utc) {
  DateTime lastSunday(int month) {
    final lastDay = DateTime.utc(utc.year, month + 1, 0);
    return lastDay.subtract(Duration(days: lastDay.weekday % 7));
  }

  final start = lastSunday(3).add(const Duration(hours: 1)); // 01:00 UTC
  final end = lastSunday(10).add(const Duration(hours: 1));
  return !utc.isBefore(start) && utc.isBefore(end);
}
