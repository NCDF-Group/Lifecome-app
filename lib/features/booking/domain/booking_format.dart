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
