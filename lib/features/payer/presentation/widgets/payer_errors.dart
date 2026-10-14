import '../../../../core/network/api_exception.dart';

/// Puts a failed membership check into words a member can act on. The backend
/// reports why in brackets — `Your membership could not be verified
/// (not_found).` — which is not something to show a patient.
String membershipErrorMessage(ApiException error, String plan) {
  if (error.code != 'MEMBERSHIP_NOT_VERIFIED') return error.message;
  final reason = RegExp(r'\((\w+)\)').firstMatch(error.message)?.group(1);
  return switch (reason) {
    'not_found' =>
      "We couldn't find that membership number with $plan. Check it "
          'against your card and try again.',
    'mismatch' => "Those details don't match $plan's records.",
    'manual_review' =>
      '$plan needs to check this one by hand. Message the care team and '
          "we'll help.",
    'payer_unavailable' =>
      "$plan isn't responding right now. Please try again in a few minutes.",
    _ => error.message,
  };
}
