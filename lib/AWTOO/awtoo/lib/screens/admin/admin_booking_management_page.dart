import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class AdminBookingManagementPage extends StatefulWidget {
  const AdminBookingManagementPage({super.key});

  @override
  State<AdminBookingManagementPage> createState() =>
      _AdminBookingManagementPageState();
}

class _AdminBookingManagementPageState
    extends State<AdminBookingManagementPage> {
  bool loading = true;
  List<Map<String, dynamic>> bookings = <Map<String, dynamic>>[];
  DateTime selectedDate = DateTime.now();

  String get bookingDate => selectedDate.toIso8601String().substring(0, 10);

  @override
  void initState() {
    super.initState();
    loadBookings();
  }

  Future<void> loadBookings() async {
    setState(() => loading = true);

    final List<Map<String, dynamic>> data = await DatabaseHelper.instance
        .getBookingsByDate(bookingDate);

    if (!mounted) return;

    setState(() {
      bookings = data;
      loading = false;
    });
  }

  String statusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Хүлээгдэж байна';
      case 'confirmed':
        return 'Баталгаажсан';
      case 'done':
        return 'Дууссан';
      case 'cancelled':
        return 'Цуцлагдсан';
      default:
        return status;
    }
  }

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'done':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> updateStatus(int id, String status) async {
    await DatabaseHelper.instance.updateBookingStatus(id: id, status: status);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Статус "$status" болж шинэчлэгдлээ')),
    );

    loadBookings();
  }

  Future<void> pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );

    if (picked == null) return;

    setState(() {
      selectedDate = picked;
    });

    loadBookings();
  }

  Future<void> reassignWorker(Map<String, dynamic> booking) async {
    final int bookingId = ((booking['id'] as num?) ?? 0).toInt();

    final List<Map<String, dynamic>> workers = await DatabaseHelper.instance
        .getAvailableWorkersForExistingBooking(bookingId: bookingId);

    if (!mounted) return;

    if (workers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Солих боломжтой ажилчин алга')),
      );
      return;
    }

    int selectedWorkerId = ((booking['workerId'] as num?) ?? 0).toInt();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ажилчин солих'),
          content: StatefulBuilder(
            builder: (context, setLocalState) {
              return DropdownButtonFormField<int>(
                initialValue: selectedWorkerId == 0 ? null : selectedWorkerId,
                decoration: const InputDecoration(
                  labelText: 'Ажилчин сонгох',
                  border: OutlineInputBorder(),
                ),
                items: workers.map<DropdownMenuItem<int>>((worker) {
                  final int id = ((worker['id'] as num?) ?? 0).toInt();
                  final String code = worker['workerCode']?.toString() ?? 'N/A';
                  final String name = worker['fullName']?.toString() ?? '-';

                  return DropdownMenuItem<int>(
                    value: id,
                    child: Text('$code - $name'),
                  );
                }).toList(),
                onChanged: (int? value) {
                  if (value == null) return;
                  setLocalState(() {
                    selectedWorkerId = value;
                  });
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Болих'),
            ),
            ElevatedButton(
              onPressed: () async {
                final Map<String, dynamic> selected = workers.firstWhere(
                  (w) => ((w['id'] as num?) ?? 0).toInt() == selectedWorkerId,
                );

                await DatabaseHelper.instance.updateBookingWorker(
                  bookingId: bookingId,
                  workerId: selectedWorkerId,
                  workerName: selected['fullName']?.toString() ?? '',
                );

                if (!mounted) return;

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ажилчин амжилттай солигдлоо')),
                );

                loadBookings();
              },
              child: const Text('Хадгалах'),
            ),
          ],
        );
      },
    );
  }

  Widget buildBookingCard(Map<String, dynamic> booking) {
    final int id = ((booking['id'] as num?) ?? 0).toInt();
    final String customerName = booking['customerName']?.toString() ?? '-';
    final String phone = booking['phone']?.toString() ?? '-';
    final String carPlate = booking['carPlate']?.toString() ?? '-';
    final String time = booking['bookingTime']?.toString() ?? '-';
    final String endTime = booking['endTime']?.toString() ?? '-';
    final String workerName = booking['workerName']?.toString() ?? '-';
    final String serviceType = booking['serviceType']?.toString() ?? '-';
    final String status = booking['status']?.toString() ?? 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: statusColor(status).withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: statusColor(status).withValues(alpha: 0.12),
                child: Icon(Icons.event_note, color: statusColor(status)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$customerName • $carPlate',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
          const SizedBox(height: 12),
          Text('ID: $id'),
          Text('📞 Утас: $phone'),
          Text('🧼 Үйлчилгээ: $serviceType'),
          Text('⏰ Цаг: $time - $endTime'),
          Text('👷 Ажилчин: $workerName'),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: status == 'confirmed'
                    ? null
                    : () => updateStatus(id, 'confirmed'),
                icon: const Icon(Icons.check_circle),
                label: const Text('Confirm'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: status == 'done'
                    ? null
                    : () => updateStatus(id, 'done'),
                icon: const Icon(Icons.task_alt),
                label: const Text('Done'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () => reassignWorker(booking),
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Worker солих'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: status == 'cancelled'
                    ? null
                    : () => updateStatus(id, 'cancelled'),
                icon: const Icon(Icons.cancel),
                label: const Text('Cancel'),
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
        title: const Text('Booking Management'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: pickDate,
            icon: const Icon(Icons.calendar_month),
          ),
          IconButton(onPressed: loadBookings, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadBookings,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Өдрийн захиалгууд',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          bookingDate,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Нийт: ${bookings.length}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (bookings.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Text('Энэ өдөр захиалга алга'),
                    )
                  else
                    ...bookings.map(buildBookingCard),
                ],
              ),
            ),
    );
  }
}
