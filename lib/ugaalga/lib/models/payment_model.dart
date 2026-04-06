class PaymentModel {
  final int amount;
  final String method; // cash / qpay
  final DateTime time;

  PaymentModel({
    required this.amount,
    required this.method,
    required this.time,
  });
}
