/// Where a payment is. The backend's `payment_status`.
enum PaymentStatus {
  initiated('initiated'),
  pending('pending'),
  successful('successful'),
  failed('failed'),
  cancelled('cancelled'),
  refunded('refunded'),
  partiallyRefunded('partially_refunded');

  const PaymentStatus(this.apiValue);

  final String apiValue;

  static PaymentStatus parse(Object? value) {
    for (final status in values) {
      if (status.apiValue == value) return status;
    }
    return pending;
  }
}
