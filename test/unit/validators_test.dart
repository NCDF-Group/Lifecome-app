import 'package:flutter_test/flutter_test.dart';
import 'package:lifecome_mobile/core/utils/validators.dart';

void main() {
  group('email', () {
    test('accepts ordinary addresses', () {
      for (final good in [
        'alex@example.com',
        'alex.morgan+care@sub.example.co.uk',
        "o'brien@example.org",
        '  padded@example.com  ',
      ]) {
        expect(Validators.email(good), isNull, reason: good);
      }
    });

    test('rejects missing and malformed addresses', () {
      expect(Validators.email(null), 'Enter your email address.');
      expect(Validators.email('   '), 'Enter your email address.');
      for (final bad in [
        'alex',
        'alex@',
        '@example.com',
        'alex@example',
        'alex@@example.com',
        'a lex@example.com',
        'alex@example..com',
        'alex@-example.com',
      ]) {
        expect(
          Validators.email(bad),
          'Enter a valid email address.',
          reason: bad,
        );
      }
    });

    test('rejects an address over 254 characters', () {
      final long = '${'a' * 250}@example.com';
      expect(Validators.email(long), 'That email address is too long.');
    });
  });

  group('newPassword', () {
    test('accepts a password that meets every rule', () {
      expect(Validators.newPassword('Sunny-Day9'), isNull);
    });

    test('names the first rule that fails', () {
      expect(Validators.newPassword(''), 'Enter a password.');
      expect(Validators.newPassword('Ab1!'), 'Use at least 8 characters.');
      for (final weak in [
        'alllowercase1!',
        'ALLUPPERCASE1!',
        'NoNumbers!!',
        'NoSymbols123',
      ]) {
        expect(
          Validators.newPassword(weak),
          'Include an uppercase letter, a lowercase letter, a number and a symbol.',
          reason: weak,
        );
      }
    });

    test('caps the length at the backend limit', () {
      expect(
        Validators.newPassword('Aa1!${'x' * 200}'),
        'Use 200 characters or fewer.',
      );
    });
  });

  group('currentPassword and confirmPassword', () {
    test('a sign-in password only has to be present', () {
      expect(Validators.currentPassword(''), 'Enter your password.');
      expect(Validators.currentPassword(null), 'Enter your password.');
      expect(Validators.currentPassword('x'), isNull);
    });

    test('confirmation must be present and match', () {
      expect(
        Validators.confirmPassword('', 'Abc1!xyz'),
        'Confirm your password.',
      );
      expect(
        Validators.confirmPassword('Abc1!xyZ', 'Abc1!xyz'),
        'Passwords do not match.',
      );
      expect(Validators.confirmPassword('Abc1!xyz', 'Abc1!xyz'), isNull);
    });
  });

  group('personName', () {
    test('accepts real names', () {
      for (final good in [
        'Alex',
        'Mary-Jane',
        "O'Brien",
        'Zoë',
        'Okafor Eze',
        'St. John',
      ]) {
        expect(
          Validators.personName(good, label: 'first name'),
          isNull,
          reason: good,
        );
      }
    });

    test('rejects empty, numeric and over-long names', () {
      expect(
        Validators.personName('  ', label: 'first name'),
        'Enter your first name.',
      );
      expect(
        Validators.personName('R2D2', label: 'last name'),
        'Use letters only in your last name (spaces, hyphens and apostrophes are fine).',
      );
      expect(Validators.personName('-Alex', label: 'first name'), isNotNull);
      expect(
        Validators.personName('a' * 101, label: 'first name'),
        'Keep your first name to 100 characters or fewer.',
      );
    });
  });

  group('UK mobile numbers', () {
    test('normalises every way people write one', () {
      for (final input in [
        '07700 900123',
        '7700900123',
        '+44 7700 900123',
        '+44 (0)7700 900123',
        '0044 7700 900123',
        '07700-900-123',
        '+447700900123',
        '447700900123',
      ]) {
        expect(
          Validators.normalizeUkMobile(input),
          '+447700900123',
          reason: input,
        );
        expect(Validators.ukMobile(input), isNull, reason: input);
      }
    });

    test('rejects landlines, short numbers and other countries', () {
      expect(Validators.ukMobile(''), 'Enter your mobile number.');
      for (final bad in [
        '020 7946 0958', // London landline
        '07700 90012', // one digit short
        '07700 9001234', // one digit long
        '+1 415 555 0132', // US
        'abc',
        '07700 90012x',
      ]) {
        expect(
          Validators.ukMobile(bad),
          'Enter a valid UK mobile number, like 7700 900123.',
          reason: bad,
        );
        expect(Validators.normalizeUkMobile(bad), isNull, reason: bad);
      }
    });
  });

  group('UK phone numbers (mobile or landline)', () {
    test('accepts mobiles and landlines however they are written', () {
      expect(Validators.normalizeUkPhone('07700 900123'), '+447700900123');
      expect(Validators.normalizeUkPhone('020 7946 0958'), '+442079460958');
      expect(
        Validators.normalizeUkPhone('+44 (0)113 496 0000'),
        '+441134960000',
      );
      expect(Validators.ukPhone(''), isNull);
      expect(
        Validators.ukPhone('', required: true),
        'Enter a phone number we can reach you on.',
      );
    });

    test('rejects numbers that cannot be reached', () {
      for (final bad in ['12345', '0800 123 4567', '+1 415 555 0132', 'abc']) {
        expect(Validators.normalizeUkPhone(bad), isNull, reason: bad);
        expect(
          Validators.ukPhone(bad),
          startsWith('Enter a valid UK phone number'),
          reason: bad,
        );
      }
    });
  });

  group('otpCode', () {
    test('needs exactly the right number of digits', () {
      expect(Validators.otpCode(''), 'Enter the 6-digit code.');
      expect(Validators.otpCode('12345'), 'The code is 6 digits.');
      expect(Validators.otpCode('1234567'), 'The code is 6 digits.');
      expect(Validators.otpCode('12a456'), 'The code is 6 digits.');
      expect(Validators.otpCode('123456'), isNull);
      expect(Validators.otpCode(' 123456 '), isNull);
      expect(Validators.otpCode('1234', length: 4), isNull);
    });
  });

  group('dateOfBirth', () {
    final today = DateTime(2026, 10, 14);

    test('accepts an adult', () {
      expect(
        Validators.dateOfBirth(DateTime(1990, 5, 20), today: today),
        isNull,
      );
    });

    test('is required', () {
      expect(
        Validators.dateOfBirth(null, today: today),
        'Enter your date of birth.',
      );
    });

    test('rejects the future and under-18s', () {
      expect(
        Validators.dateOfBirth(DateTime(2027, 1, 1), today: today),
        "Your date of birth can't be in the future.",
      );
      expect(
        Validators.dateOfBirth(DateTime(2010, 1, 1), today: today),
        'You must be 18 or over to use LifeCome Live.',
      );
    });

    test('turns 18 on the birthday itself, not the day before', () {
      expect(
        Validators.dateOfBirth(DateTime(2008, 10, 14), today: today),
        isNull,
      );
      expect(
        Validators.dateOfBirth(DateTime(2008, 10, 15), today: today),
        'You must be 18 or over to use LifeCome Live.',
      );
    });

    test('rejects an implausibly old date', () {
      expect(
        Validators.dateOfBirth(DateTime(1900, 1, 1), today: today),
        'Check your date of birth.',
      );
    });

    test('ageOn counts whole years', () {
      expect(
        Validators.ageOn(DateTime(2000, 2, 29), DateTime(2026, 2, 28)),
        25,
      );
      expect(Validators.ageOn(DateTime(2000, 2, 29), DateTime(2026, 3, 1)), 26);
    });
  });

  group('ukPostcode', () {
    test('accepts valid postcodes in any case and spacing', () {
      for (final good in [
        'SW1A 1AA',
        'sw1a1aa',
        'M1 1AE',
        'B33 8TH',
        'EC1A 1BB',
        'GIR 0AA',
      ]) {
        expect(Validators.ukPostcode(good), isNull, reason: good);
      }
    });

    test('rejects the rest and honours optional', () {
      expect(Validators.ukPostcode(''), 'Enter your postcode.');
      expect(Validators.ukPostcode('', required: false), isNull);
      for (final bad in ['12345', 'SW1A', 'ABCDE', 'SW1A 1A', 'SW1A 1AAA']) {
        expect(
          Validators.ukPostcode(bad),
          'Enter a valid UK postcode, like SW1A 1AA.',
          reason: bad,
        );
      }
    });
  });

  group('place', () {
    test('optional by default, validated when given', () {
      expect(Validators.place('', label: 'town or city'), isNull);
      expect(
        Validators.place('', label: 'town or city', required: true),
        'Enter your town or city.',
      );
      expect(
        Validators.place('Newcastle upon Tyne', label: 'town or city'),
        isNull,
      );
      expect(Validators.place("King's Lynn", label: 'town or city'), isNull);
      expect(
        Validators.place('123', label: 'town or city'),
        'Enter a valid town or city.',
      );
    });
  });

  group('text', () {
    test('required, minimum and maximum lengths', () {
      expect(
        Validators.text('  ', label: 'a message', required: true),
        'Enter a message.',
      );
      expect(Validators.text('', label: 'a message'), isNull);
      expect(
        Validators.text('hi', label: 'a reason', minLength: 10),
        'Add a little more detail (at least 10 characters).',
      );
      expect(
        Validators.text('x' * 11, label: 'a reason', maxLength: 10),
        'Keep this to 10 characters or fewer (it is 11 now).',
      );
      expect(
        Validators.text('x' * 10, label: 'a reason', maxLength: 10),
        isNull,
      );
    });

    test('measures the trimmed text', () {
      expect(
        Validators.text('   ${'x' * 10}   ', label: 'a reason', maxLength: 10),
        isNull,
      );
    });
  });

  group('health plan and access codes', () {
    test('memberId', () {
      expect(Validators.memberId(''), 'Enter your membership number.');
      expect(
        Validators.memberId('ab'),
        'Membership numbers are 3 to 40 characters.',
      );
      expect(
        Validators.memberId('A' * 41),
        'Membership numbers are 3 to 40 characters.',
      );
      expect(
        Validators.memberId('AB#123'),
        'Use letters, numbers, spaces and dashes only.',
      );
      expect(Validators.memberId('BUP-123 456/7'), isNull);
    });

    test('accessCode', () {
      expect(Validators.accessCode(''), 'Enter your invitation code.');
      expect(
        Validators.accessCode('abc'),
        'Codes are 4 to 20 letters and numbers.',
      );
      expect(
        Validators.accessCode('ABCD EFGH'),
        'Codes are 4 to 20 letters and numbers.',
      );
      expect(Validators.accessCode('WORK-2026'), isNull);
    });

    test('searchQuery is optional but bounded', () {
      expect(Validators.searchQuery(null), isNull);
      expect(Validators.searchQuery('a' * 100), isNull);
      expect(
        Validators.searchQuery('a' * 101),
        'Search for 100 characters or fewer.',
      );
    });
  });

  test('firstError returns the first failing check only', () {
    var calls = 0;
    final result = Validators.firstError([
      () {
        calls++;
        return null;
      },
      () {
        calls++;
        return 'first';
      },
      () {
        calls++;
        return 'second';
      },
    ]);
    expect(result, 'first');
    expect(calls, 2);
  });
}
