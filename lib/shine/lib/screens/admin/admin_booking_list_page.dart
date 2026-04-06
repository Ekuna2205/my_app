import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class AdminBookingListPage extends StatefulWidget {
  const AdminBookingListPage({super.key});

  @override
  State<AdminBookingListPage> createState() => _AdminBookingListPageState();
}

class _AdminBookingListPageState extends State<AdminBookingListPage> {
  bool loading = true;
  List<Map<String, dynamic>> bookings = <Map<String, dynamic>>[];

  final List<String> statuses = <String>[
    'pending',
    'confirmed',
    'working',
    'completed',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    loadBookings();
  }

  Future<void> loadBookings() async {
    final List<Map<String, dynamic>> data = await DatabaseHelper.instance
        .getAllBookings();

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

  Future<void> changeStatus(int id, String newStatus) async {
    await DatabaseHelper.instance.updateBookingStatus(
      id: id,
      status: newStatus,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Захиалгын төлөв шинэчлэгдлээ')),
    );

    await loadBookings();
  }

  Widget buildBookingCard(Map<String, dynamic> item) {
    final int id = ((item['id'] as num?) ?? 0).toInt();
    final String customerName = item['customerName']?.toString() ?? '';
    final String phone = item['phone']?.toString() ?? '';
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    customerName,
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
                    color: statusColor(status).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText(status),
                    style: TextStyle(
                      color: statusColor(status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('Утас: $phone'),
            Text('Машины дугаар: $carPlate'),
            Text('Огноо: $bookingDate'),
            Text('Цаг: $bookingTime'),
            Text('Үйлчилгээ: $serviceType'),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: statuses.contains(status) ? status : 'pending',
              decoration: const InputDecoration(
                labelText: 'Төлөв өөрчлөх',
                border: OutlineInputBorder(),
              ),
              items: statuses.map((String e) {
                return DropdownMenuItem<String>(
                  value: e,
                  child: Text(statusText(e)),
                );
              }).toList(),
              onChanged: (String? value) {
                if (value == null) return;
                changeStatus(id, value);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Цагийн захиалгууд'), centerTitle: true),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : bookings.isEmpty
          ? const Center(
              child: Text('Захиалга алга', style: TextStyle(fontSize: 18)),
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
