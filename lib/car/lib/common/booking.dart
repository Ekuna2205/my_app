import 'service.dart'; // ← Service class-ийг ашиглахын тулд import хийнэ

class Booking {
  final Service service;
  final DateTime dateTime;
  final String customerName;
  final String phoneNumber;

  String status; // final устгасан, одоо өөрчлөх боломжтой

  Booking({
    required this.service,
    required this.dateTime,
    required this.customerName,
    required this.phoneNumber,
    this.status = 'pending',
  });
}
