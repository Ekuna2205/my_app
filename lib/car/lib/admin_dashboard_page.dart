import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart'; // ← Энд нэмсэн

import '../common/booking_manager.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  String _statusFilter = 'Бүгд';
  String _dateFilter = 'Бүгд';

  final List<String> _statusOptions = [
    'Бүгд',
    'Хүлээгдэж байна',
    'Батлагдсан',
    'Цуцлагдсан'
  ];
  final List<String> _dateOptions = [
    'Бүгд',
    'Өнөөдөр',
    'Маргааш',
    'Сүүлийн 7 хоног'
  ];

  @override
  Widget build(BuildContext context) {
    final allBookings = BookingManager.getUserBookings();

    final filteredBookings = allBookings.where((booking) {
      // Статусаар шүүх
      if (_statusFilter != 'Бүгд') {
        final targetStatus = _statusFilter == 'Хүлээгдэж байна'
            ? 'pending'
            : _statusFilter == 'Батлагдсан'
                ? 'confirmed'
                : 'cancelled';
        if (booking.status != targetStatus) return false;
      }

      // Огноогоор шүүх
      if (_dateFilter != 'Бүгд') {
        final now = DateTime.now();
        final bookingDate = DateTime(
          booking.dateTime.year,
          booking.dateTime.month,
          booking.dateTime.day,
        );

        if (_dateFilter == 'Өнөөдөр') {
          final today = DateTime(now.year, now.month, now.day);
          if (!isSameDay(bookingDate, today)) return false;
        } else if (_dateFilter == 'Маргааш') {
          final tomorrow = now.add(const Duration(days: 1));
          final tomorrowDate =
              DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
          if (!isSameDay(bookingDate, tomorrowDate)) return false;
        } else if (_dateFilter == 'Сүүлийн 7 хоног') {
          if (bookingDate.isBefore(now.subtract(const Duration(days: 7)))) {
            return false;
          }
        }
      }

      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Админ - Бүх захиалга'),
        centerTitle: true,
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.grey[50],
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _statusFilter,
                    decoration: InputDecoration(
                      labelText: 'Статус',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    items: _statusOptions
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _statusFilter = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _dateFilter,
                    decoration: InputDecoration(
                      labelText: 'Огноо',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    items: _dateOptions
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _dateFilter = v!),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredBookings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_outlined,
                            size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Захиалга байхгүй',
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredBookings.length,
                    itemBuilder: (context, index) {
                      final booking = filteredBookings[index];

                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue[100],
                            child: const Icon(Icons.local_car_wash,
                                color: Colors.blue),
                          ),
                          title: Text(
                            booking.service.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text('Хэрэглэгч: ${booking.customerName}'),
                              Text('Утас: ${booking.phoneNumber}'),
                              Text(
                                'Цаг: ${booking.dateTime.year}.${booking.dateTime.month.toString().padLeft(2, '0')}.${booking.dateTime.day.toString().padLeft(2, '0')} '
                                '${booking.dateTime.hour.toString().padLeft(2, '0')}:${booking.dateTime.minute.toString().padLeft(2, '0')}',
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Chip(
                                label: Text(
                                  booking.status == 'confirmed'
                                      ? 'Батлагдсан'
                                      : booking.status == 'cancelled'
                                          ? 'Цуцлагдсан'
                                          : 'Хүлээгдэж байна',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: booking.status == 'confirmed'
                                    ? Colors.green[100]
                                    : booking.status == 'cancelled'
                                        ? Colors.red[100]
                                        : Colors.orange[100],
                              ),
                              const SizedBox(width: 8),
                              if (booking.status == 'pending')
                                IconButton(
                                  icon: const Icon(Icons.check_circle,
                                      color: Colors.green),
                                  tooltip: 'Батлах',
                                  onPressed: () {
                                    setState(() {
                                      booking.status = 'confirmed';
                                    });
                                  },
                                ),
                              if (booking.status != 'cancelled')
                                IconButton(
                                  icon: const Icon(Icons.cancel,
                                      color: Colors.red),
                                  tooltip: 'Цуцлах',
                                  onPressed: () {
                                    setState(() {
                                      booking.status = 'cancelled';
                                    });
                                  },
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
