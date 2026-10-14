import 'package:flutter_test/flutter_test.dart';
import 'package:lifecome_mobile/core/utils/formatters.dart';

void main() {
  group('money', () {
    test('shows pence as pounds, with thousands separators', () {
      expect(Formatters.money(6000), '£60.00');
      expect(Formatters.money(4550), '£45.50');
      expect(Formatters.money(5), '£0.05');
      expect(Formatters.money(123456789), '£1,234,567.89');
      expect(Formatters.money(-250), '-£2.50');
    });
  });

  group('dates', () {
    test('formats the way a UK reader expects', () {
      final day = DateTime(2026, 10, 14);
      expect(Formatters.isoDate(day), '2026-10-14');
      expect(Formatters.date(day), '14 Oct 2026');
      expect(Formatters.shortDate(day), 'Wed 14 Oct');
      expect(Formatters.longDate(day), 'Wednesday 14 October 2026');
      expect(Formatters.dateField(day), '14 / 10 / 2026');
      expect(Formatters.time(DateTime(2026, 10, 14, 9, 5)), '09:05');
    });

    test('reads a backend date with no time zone shifting it', () {
      expect(Formatters.parseDate('1990-05-20'), DateTime(1990, 5, 20));
      expect(
        Formatters.parseDate('1990-05-20T23:30:00.000Z'),
        DateTime(1990, 5, 20),
      );
      expect(Formatters.parseDate(null), isNull);
      expect(Formatters.parseDate('nope'), isNull);
    });

    test('says today, tomorrow and yesterday', () {
      final now = DateTime(2026, 10, 14, 15);
      expect(Formatters.dayLabel(DateTime(2026, 10, 14), now: now), 'Today');
      expect(Formatters.dayLabel(DateTime(2026, 10, 15), now: now), 'Tomorrow');
      expect(
        Formatters.dayLabel(DateTime(2026, 10, 13), now: now),
        'Yesterday',
      );
      expect(
        Formatters.dayLabel(DateTime(2026, 10, 20), now: now),
        'Tue 20 Oct',
      );
    });

    test('relative times', () {
      final now = DateTime(2026, 10, 14, 12);
      expect(
        Formatters.relative(DateTime(2026, 10, 14, 11, 59, 40), now: now),
        'just now',
      );
      expect(
        Formatters.relative(DateTime(2026, 10, 14, 11, 55), now: now),
        '5 minutes ago',
      );
      expect(
        Formatters.relative(DateTime(2026, 10, 14, 11), now: now),
        '1 hour ago',
      );
      expect(
        Formatters.relative(DateTime(2026, 10, 14, 9), now: now),
        '3 hours ago',
      );
      expect(
        Formatters.relative(DateTime(2026, 10, 13, 9), now: now),
        'Yesterday',
      );
      expect(
        Formatters.relative(DateTime(2026, 10, 1, 9), now: now),
        '1 Oct 2026',
      );
    });
  });

  group('UK time', () {
    test(
      'switches to summer time on the last Sunday of March at 01:00 UTC',
      () {
        // 2026: clocks go forward on Sunday 29 March.
        expect(
          Formatters.isUkSummerTime(DateTime.utc(2026, 3, 29, 0, 59)),
          isFalse,
        );
        expect(
          Formatters.isUkSummerTime(DateTime.utc(2026, 3, 29, 1, 0)),
          isTrue,
        );
      },
    );

    test('switches back on the last Sunday of October at 01:00 UTC', () {
      // 2026: clocks go back on Sunday 25 October.
      expect(
        Formatters.isUkSummerTime(DateTime.utc(2026, 10, 25, 0, 59)),
        isTrue,
      );
      expect(
        Formatters.isUkSummerTime(DateTime.utc(2026, 10, 25, 1, 0)),
        isFalse,
      );
    });

    test('shows an appointment in UK time whatever the phone says', () {
      final summer = DateTime.utc(2026, 7, 1, 9, 30);
      expect(Formatters.time(Formatters.ukTime(summer)), '10:30');
      expect(Formatters.ukZoneLabel(summer), 'BST');
      final winter = DateTime.utc(2026, 12, 1, 9, 30);
      expect(Formatters.time(Formatters.ukTime(winter)), '09:30');
      expect(Formatters.ukZoneLabel(winter), 'GMT');
      expect(
        Formatters.appointmentWhen(summer),
        'Wednesday 1 July 2026 at 10:30',
      );
    });

    test('a late-evening UTC time can be the next day in UK summer time', () {
      final late = DateTime.utc(2026, 7, 1, 23, 30);
      final uk = Formatters.ukTime(late);
      expect(uk.day, 2);
      expect(Formatters.time(uk), '00:30');
    });
  });

  group('phone numbers', () {
    test('writes a UK number the way people do', () {
      expect(Formatters.ukPhone('+447700900123'), '07700 900123');
      expect(Formatters.ukPhone('+442079460958'), '020 7946 0958');
      expect(Formatters.ukPhone('+441134960000'), '01134 960000');
      expect(Formatters.ukPhone('+15551234567'), '+15551234567');
    });
  });
}
