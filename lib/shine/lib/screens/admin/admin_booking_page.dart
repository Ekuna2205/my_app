import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class AdminBookingPage extends StatefulWidget {
  const AdminBookingPage({super.key});

  @override
  State<AdminBookingPage> createState() => _AdminBookingPageState();
}

class _AdminBookingPageState extends State<AdminBookingPage> {
  List<Map<String, dynamic>> bookings = <Map<String, dynamic>>[];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadBookings();
  }

  Future<void> loadBookings() async {
    final data = await DatabaseHelper.instance.getAllBookings();

    if (!mounted) return;

    setState(() {
      bookings = data;
      loading = false;
    });
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'done':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Хүлээгдэж байна';
      case 'done':
        return 'Дууссан';
      case 'cancelled':
        return 'Цуцлагдсан';
      default:
        return status;
    }
  }

  int extractPrice(String serviceType) {
    final RegExp reg = RegExp(r'(\d+)');
    final match = reg.firstMatch(serviceType);
    if (match != null) {
      return int.parse(match.group(1)!);
    }
    return 0;
  }

  Future<void> updateStatus(int id, String status) async {
    await DatabaseHelper.instance.updateBookingStatus(id: id, status: status);

    loadBookings();
  }

  Widget buildBookingCard(Map<String, dynamic> booking) {
    final int id = booking['id'];
    final String name = booking['customerName'];
    final String phone = booking['phone'];
    final String plate = booking['carPlate'];
    final String date = booking['bookingDate'];
    final String time = booking['bookingTime'];
    final String service = booking['serviceType'];
    final String status = booking['status'];

    final int price = extractPrice(service);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TOP ROW
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: getStatusColor(status).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  getStatusText(status),
                  style: TextStyle(
                    color: getStatusColor(status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text('📞 $phone'),
          Text('🚗 $plate'),
          Text('🕒 $date  $time'),
          Text('🧼 $service'),

          const SizedBox(height: 10),

          /// 💰 PRICE
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.payments, color: Colors.orange),
                const SizedBox(width: 8),
                const Text('Төлбөр:'),
                const Spacer(),
                Text(
                  '$price₮',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          /// ACTION BUTTONS
          if (status == 'pending')
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => updateStatus(id, 'done'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Батлах'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => updateStatus(id, 'cancelled'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Цуцлах'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Захиалгын жагсаалт'),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : bookings.isEmpty
          ? const Center(child: Text('Захиалга алга'))
          : RefreshIndicator(
              onRefresh: loadBookings,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  return buildBookingCard(bookings[index]);
                },
              ),
            ),
    );
  }
}
