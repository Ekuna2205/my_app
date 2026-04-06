import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class CustomerBookingHistory extends StatefulWidget {
  final String phone;

  const CustomerBookingHistory({super.key, required this.phone});

  @override
  State<CustomerBookingHistory> createState() => _CustomerBookingHistoryState();
}

class _CustomerBookingHistoryState extends State<CustomerBookingHistory> {
  bool loading = true;
  List<Map<String, dynamic>> bookings = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    loadBookings();
  }

  Future<void> loadBookings() async {
    final List<Map<String, dynamic>> data = await DatabaseHelper.instance
        .getBookingsByPhone(widget.phone);

    if (!mounted) return;

    setState(() {
      bookings = data;
      loading = false;
    });
  }

  Color statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'working':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String statusText(String status) {
    switch (status) {
      case 'pending':
        return 'Хүлээгдэж байна';
      case 'confirmed':
        return 'Баталгаажсан';
      case 'working':
        return 'Ажил явагдаж байна';
      case 'completed':
        return 'Дууссан';
      case 'cancelled':
        return 'Цуцлагдсан';
      default:
        return status;
    }
  }

  Widget buildBookingCard(Map<String, dynamic> item) {
    final String customerName = item['customerName']?.toString() ?? '';
    final String carPlate = item['carPlate']?.toString() ?? '';
    final String bookingDate = item['bookingDate']?.toString() ?? '';
    final String bookingTime = item['bookingTime']?.toString() ?? '';
    final String serviceType = item['serviceType']?.toString() ?? '';
    final String status = item['status']?.toString() ?? 'pending';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              customerName,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Машины дугаар: $carPlate'),
            Text('Огноо: $bookingDate'),
            Text('Цаг: $bookingTime'),
            Text('Үйлчилгээ: $serviceType'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor(status).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusText(status),
                style: TextStyle(
                  color: statusColor(status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Миний захиалгууд'), centerTitle: true),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : bookings.isEmpty
          ? const Center(
              child: Text('Таны захиалга алга', style: TextStyle(fontSize: 18)),
            )
          : RefreshIndicator(
              onRefresh: loadBookings,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: bookings.length,
                itemBuilder: (BuildContext context, int index) {
                  return buildBookingCard(bookings[index]);
                },
              ),
            ),
    );
  }
}
