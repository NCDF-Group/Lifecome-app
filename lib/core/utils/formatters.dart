/// Turns backend values into the words and numbers shown on screen.
///
/// The backend sends instants as UTC ISO-8601 strings and money as whole minor
/// units (pence); everything here shows them the way a UK reader expects:
/// `14 Oct 2026`, `14:30`, `£45.00`.
abstract final class Formatters {
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  static const _monthsLong = [
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
  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _weekdaysLong = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static String _two(int value) => value.toString().padLeft(2, '0');

  /// `2026-10-14` — the form the backend takes for a date with no time.
  static String isoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${_two(date.month)}-${_two(date.day)}';

  /// Reads the backend's `2026-10-14` (or a full timestamp) as a calendar
  /// date with no time zone shifting it onto the wrong day.
  static DateTime? parseDate(Object? value) {
    if (value is! String || value.length < 10) return null;
    final parsed = DateTime.tryParse(value.substring(0, 10));
    return parsed == null
        ? null
        : DateTime(parsed.year, parsed.month, parsed.day);
  }

  /// Reads a backend instant and returns it in the phone's own time zone.
  static DateTime? parseInstant(Object? value) {
    if (value is! String) return null;
    return DateTime.tryParse(value)?.toLocal();
  }

  /// `14 Oct 2026`
  static String date(DateTime date) =>
      '${date.day} ${_months[date.month - 1]} ${date.year}';

  /// `Wed 14 Oct`
  static String shortDate(DateTime date) =>
      '${_weekdays[date.weekday - 1]} ${date.day} ${_months[date.month - 1]}';

  /// `Wednesday 14 October 2026`
  static String longDate(DateTime date) =>
      '${_weekdaysLong[date.weekday - 1]} ${date.day} ${_monthsLong[date.month - 1]} ${date.year}';

  /// `14 / 10 / 2026` — how a date of birth is shown in a form field.
  static String dateField(DateTime date) =>
      '${_two(date.day)} / ${_two(date.month)} / ${date.year}';

  /// `14:30`
  static String time(DateTime time) =>
      '${_two(time.hour)}:${_two(time.minute)}';

  /// `14:30 – 15:00`
  static String timeRange(DateTime start, DateTime end) =>
      '${time(start)} – ${time(end)}';

  /// `Today`, `Tomorrow`, or `Wed 14 Oct`, judged against [now].
  static String dayLabel(DateTime day, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final startOfDay = DateTime(day.year, day.month, day.day);
    final days = startOfDay.difference(startOfToday).inDays;
    if (days == 0) return 'Today';
    if (days == 1) return 'Tomorrow';
    if (days == -1) return 'Yesterday';
    return shortDate(day);
  }

  /// `£45.00` from [minorUnits] (pence). Whole pounds still show `.00` so a
  /// column of prices lines up.
  static String money(int minorUnits, {String currency = 'GBP'}) {
    final symbol = switch (currency) {
      'GBP' => '£',
      'NGN' => '₦',
      'USD' => r'$',
      'EUR' => '€',
      _ => '$currency ',
    };
    final negative = minorUnits < 0;
    final absolute = minorUnits.abs();
    final major = absolute ~/ 100;
    final minor = _two(absolute % 100);
    final grouped = major.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return '${negative ? '-' : ''}$symbol$grouped.$minor';
  }

  /// `just now`, `5 minutes ago`, `2 hours ago`, `Yesterday`, or a date.
  static String relative(DateTime time, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final difference = reference.difference(time);
    if (difference.isNegative) return Formatters.date(time);
    if (difference.inMinutes < 1) return 'just now';
    if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    }
    if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    }
    if (difference.inHours < 48) return 'Yesterday';
    return Formatters.date(time);
  }
}
