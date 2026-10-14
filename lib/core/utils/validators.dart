/// Field validation shared by every form in the app.
///
/// Each validator takes what the person typed and returns the message to show
/// under the field, or `null` when the value is fine. They trim whitespace
/// themselves, so a screen can pass a controller's text straight in.
///
/// The limits mirror the backend's own (see Lifecome-Backend's Zod schemas), so
/// the app rejects what the server would reject before making a request —
/// and says why in plain words.
abstract final class Validators {
  /// The service is for adults; younger people are added as dependants.
  static const minimumAge = 18;
  static const maximumAge = 120;

  static final _email = RegExp(
    r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)*\.[A-Za-z]{2,}$",
  );
  static final _personName = RegExp(
    r"^[\p{L}][\p{L}\p{M}' .-]*$",
    unicode: true,
  );
  static final _ukPostcode = RegExp(
    r'^(GIR 0AA|[A-Z]{1,2}\d[A-Z\d]? ?\d[A-Z]{2})$',
    caseSensitive: false,
  );
  static final _memberId = RegExp(r'^[A-Za-z0-9][A-Za-z0-9 /\-]*$');
  static final _accessCode = RegExp(r'^[A-Za-z0-9-]{4,20}$');
  static final _place = RegExp(
    r"^[\p{L}][\p{L}\p{M}0-9' .,-]*$",
    unicode: true,
  );

  // ---- Account ------------------------------------------------------------

  static String? email(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Enter your email address.';
    if (text.length > 254) return 'That email address is too long.';
    if (!_email.hasMatch(text)) return 'Enter a valid email address.';
    return null;
  }

  /// A new password (sign-up, reset): the same rules the password checklist
  /// shows under the field — 8+ characters with an uppercase letter, a
  /// lowercase letter, a number and a symbol.
  static String? newPassword(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Enter a password.';
    if (text.length < 8) return 'Use at least 8 characters.';
    if (text.length > 200) return 'Use 200 characters or fewer.';
    if (!passwordMeetsRules(text)) {
      return 'Include an uppercase letter, a lowercase letter, a number and a symbol.';
    }
    return null;
  }

  /// An existing password being typed to sign in: only has to be present —
  /// rejecting it for its shape would leak the rules to someone guessing.
  static String? currentPassword(String? value) {
    if ((value ?? '').isEmpty) return 'Enter your password.';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if ((value ?? '').isEmpty) return 'Confirm your password.';
    if (value != original) return 'Passwords do not match.';
    return null;
  }

  static bool passwordMeetsRules(String password) =>
      password.length >= 8 &&
      RegExp(r'[a-z]').hasMatch(password) &&
      RegExp(r'[A-Z]').hasMatch(password) &&
      RegExp(r'\d').hasMatch(password) &&
      RegExp(r'[^A-Za-z0-9]').hasMatch(password);

  /// A first or last name. [label] reads naturally in a sentence
  /// ("first name", "last name").
  static String? personName(String? value, {required String label}) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Enter your $label.';
    if (text.length > 100) {
      return 'Keep your $label to 100 characters or fewer.';
    }
    if (!_personName.hasMatch(text)) {
      return 'Use letters only in your $label (spaces, hyphens and apostrophes are fine).';
    }
    return null;
  }

  // ---- Phone --------------------------------------------------------------

  /// The number as the backend wants it (`+447700900123`), or null when it is
  /// not a UK mobile. Accepts what people actually type: `07700 900123`,
  /// `7700900123`, `+44 7700 900123`, `0044 7700 900123`.
  static String? normalizeUkMobile(String? value) {
    var digits = (value ?? '').replaceAll(RegExp(r'[\s\-().]'), '');
    if (digits.isEmpty) return null;
    if (digits.startsWith('+')) {
      digits = digits.substring(1);
    } else if (digits.startsWith('00')) {
      digits = digits.substring(2);
    }
    if (!RegExp(r'^\d+$').hasMatch(digits)) return null;

    if (digits.startsWith('44')) {
      digits = digits.substring(2);
      // People write +44 (0)7700...
      if (digits.startsWith('0')) digits = digits.substring(1);
    } else if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    // A UK mobile is 07 followed by nine digits: ten digits starting 7.
    if (!RegExp(r'^7\d{9}$').hasMatch(digits)) return null;
    return '+44$digits';
  }

  static String? ukMobile(String? value) {
    if ((value ?? '').trim().isEmpty) return 'Enter your mobile number.';
    if (normalizeUkMobile(value) == null) {
      return 'Enter a valid UK mobile number, like 7700 900123.';
    }
    return null;
  }

  /// The number as the backend wants it (`+442079460958`) for any UK number
  /// someone could be rung on — a mobile or a landline — or null when it is
  /// not one.
  static String? normalizeUkPhone(String? value) {
    var digits = (value ?? '').replaceAll(RegExp(r'[\s\-().]'), '');
    if (digits.isEmpty) return null;
    if (digits.startsWith('+')) {
      digits = digits.substring(1);
    } else if (digits.startsWith('00')) {
      digits = digits.substring(2);
    }
    if (!RegExp(r'^\d+$').hasMatch(digits)) return null;
    if (digits.startsWith('44')) {
      digits = digits.substring(2);
      if (digits.startsWith('0')) digits = digits.substring(1);
    } else if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    // Geographic (01, 02), non-geographic (03) or mobile (07): ten digits
    // after the leading zero.
    if (!RegExp(r'^[1237]\d{9}$').hasMatch(digits)) return null;
    return '+44$digits';
  }

  /// A UK phone number (mobile or landline). Optional unless [required].
  static String? ukPhone(String? value, {bool required = false}) {
    if ((value ?? '').trim().isEmpty) {
      return required ? 'Enter a phone number we can reach you on.' : null;
    }
    if (normalizeUkPhone(value) == null) {
      return 'Enter a valid UK phone number, like 020 7946 0958 or '
          '07700 900123.';
    }
    return null;
  }

  // ---- Codes --------------------------------------------------------------

  static String? otpCode(String? value, {int length = 6}) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Enter the $length-digit code.';
    if (!RegExp('^\\d{$length}\$').hasMatch(text)) {
      return 'The code is $length digits.';
    }
    return null;
  }

  // ---- Personal details ---------------------------------------------------

  static String? dateOfBirth(DateTime? value, {DateTime? today}) {
    if (value == null) return 'Enter your date of birth.';
    final now = today ?? DateTime.now();
    final day = DateTime(now.year, now.month, now.day);
    if (value.isAfter(day)) return "Your date of birth can't be in the future.";
    if (ageOn(value, day) < minimumAge) {
      return 'You must be $minimumAge or over to use LifeCome Live.';
    }
    if (ageOn(value, day) > maximumAge) return 'Check your date of birth.';
    return null;
  }

  /// Whole years between [birth] and [on].
  static int ageOn(DateTime birth, DateTime on) {
    var years = on.year - birth.year;
    final hadBirthday =
        on.month > birth.month ||
        (on.month == birth.month && on.day >= birth.day);
    if (!hadBirthday) years--;
    return years;
  }

  static String? ukPostcode(String? value, {bool required = true}) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return required ? 'Enter your postcode.' : null;
    if (!_ukPostcode.hasMatch(text)) {
      return 'Enter a valid UK postcode, like SW1A 1AA.';
    }
    return null;
  }

  /// A town, city or county.
  static String? place(
    String? value, {
    required String label,
    bool required = false,
  }) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return required ? 'Enter your $label.' : null;
    if (text.length > 100) {
      return 'Keep your $label to 100 characters or fewer.';
    }
    if (!_place.hasMatch(text)) return 'Enter a valid $label.';
    return null;
  }

  // ---- Free text ----------------------------------------------------------

  /// Free text: a message, a reason for a visit. [label] finishes the
  /// sentence "Enter ..." ("your reason for the visit", "a message").
  static String? text(
    String? value, {
    required String label,
    bool required = false,
    int minLength = 0,
    int maxLength = 2000,
  }) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return required ? 'Enter $label.' : null;
    if (text.length < minLength) {
      return 'Add a little more detail (at least $minLength characters).';
    }
    if (text.length > maxLength) {
      return 'Keep this to $maxLength characters or fewer (it is ${text.length} now).';
    }
    return null;
  }

  // ---- Health plan / access ----------------------------------------------

  static String? memberId(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Enter your membership number.';
    if (text.length < 3 || text.length > 40) {
      return 'Membership numbers are 3 to 40 characters.';
    }
    if (!_memberId.hasMatch(text)) {
      return 'Use letters, numbers, spaces and dashes only.';
    }
    return null;
  }

  static String? accessCode(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Enter your invitation code.';
    if (!_accessCode.hasMatch(text)) {
      return 'Codes are 4 to 20 letters and numbers.';
    }
    return null;
  }

  /// A search box: optional, but not unbounded.
  static String? searchQuery(String? value) {
    if ((value ?? '').trim().length > 100) {
      return 'Search for 100 characters or fewer.';
    }
    return null;
  }

  /// The first non-null result of [checks] — for fields with several rules.
  static String? firstError(Iterable<String? Function()> checks) {
    for (final check in checks) {
      final error = check();
      if (error != null) return error;
    }
    return null;
  }
}
