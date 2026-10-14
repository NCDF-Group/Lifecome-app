import 'payment_status.dart';

/// A payment the backend has started for an appointment
/// (`POST /payments/intents`).
class PaymentTransaction {
  const PaymentTransaction({
    required this.id,
    required this.appointmentId,
    required this.amountMinor,
    required this.gateway,
    required this.status,
    this.gatewayReference,
    this.receiptNumber,
  });

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) =>
      PaymentTransaction(
        id: json['id'] as String,
        appointmentId: json['appointmentId'] as String,
        // The backend's column is named for Nigeria's currency, but it holds
        // the smallest unit (pence for LifeCome Live UK).
        amountMinor: (json['amountKobo'] as num?)?.toInt() ?? 0,
        gateway: json['gateway'] as String? ?? '',
        status: PaymentStatus.parse(json['status']),
        gatewayReference: json['gatewayReference'] as String?,
        receiptNumber: json['receiptNumber'] as String?,
      );

  final String id;
  final String appointmentId;
  final int amountMinor;
  final String gateway;
  final PaymentStatus status;
  final String? gatewayReference;
  final String? receiptNumber;

  bool get isPaid => status == PaymentStatus.successful;
}
