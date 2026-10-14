import 'dart:math';

final _random = Random.secure();

/// A random version-4 UUID, sent as the `Idempotency-Key` header on requests
/// that must never run twice (booking, payment).
///
/// Make one when the person starts the action and reuse it for every retry of
/// that same action: a double tap, or a retry after the connection dropped,
/// then gets the first result back instead of booking or charging twice.
String newIdempotencyKey() {
  final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
  bytes[8] = (bytes[8] & 0x3f) | 0x80; // RFC 4122 variant
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}
