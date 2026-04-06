import 'package:flutter/material.dart';
import '../common/booking_manager.dart';

class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bookings = BookingManager.getUserBookings();

    return Scaffold(
      appBar: AppBar(title: const Text('Миний захиалгууд'), centerTitle: true),
      body: bookings.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_month_outlined,
                      size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Одоогоор захиалга байхгүй байна',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: const Icon(Icons.local_car_wash,
                        color: Colors.blue, size: 36),
                    title: Text(booking.service.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      '${booking.dateTime.year}-${booking.dateTime.month.toString().padLeft(2, '0')}-${booking.dateTime.day.toString().padLeft(2, '0')} '
                      '${booking.dateTime.hour.toString().padLeft(2, '0')}:${booking.dateTime.minute.toString().padLeft(2, '0')}',
                    ),
                    trailing: Chip(
                      label: Text(
                        booking.status == 'confirmed'
                            ? 'Батлагдсан'
                            : booking.status == 'pending'
                                ? 'Хүлээгдэж байна'
                                : 'Цуцлагдсан',
                      ),
                      backgroundColor: booking.status == 'confirmed'
                          ? Colors.green[100]
                          : booking.status == 'pending'
                              ? Colors.orange[100]
                              : Colors.red[100],
                      labelStyle: TextStyle(
                        color: booking.status == 'confirmed'
                            ? Colors.green[800]
                            : booking.status == 'pending'
                                ? Colors.orange[800]
                                : Colors.red[800],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
