// lib/car/lib/confirm_booking_page.dart
import 'package:flutter/material.dart';

import '../common/service.dart';
import '../common/booking.dart';
import '../common/booking_manager.dart';
import 'booking_success_page.dart';

class ConfirmBookingPage extends StatefulWidget {
  final Service service;
  final DateTime dateTime;

  const ConfirmBookingPage({
    super.key,
    required this.service,
    required this.dateTime,
  });

  @override
  State<ConfirmBookingPage> createState() => _ConfirmBookingPageState();
}

class _ConfirmBookingPageState extends State<ConfirmBookingPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Захиалга баталгаажуулах',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D47A1),
              Color(0xFF42A5F5),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  color: Colors.white.withValues(alpha: 1.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.service.name,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 6, 6, 6)),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Үнэ: ${widget.service.price.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}₮',
                          style: const TextStyle(
                              color: Color.fromARGB(255, 9, 9, 9)),
                        ),
                        Text(
                          'Хугацаа: ${widget.service.durationMinutes} мин',
                          style: const TextStyle(
                              color: Color.fromARGB(255, 11, 11, 11)),
                        ),
                        Text(
                          'Огноо: ${widget.dateTime.year}.${widget.dateTime.month.toString().padLeft(2, '0')}.${widget.dateTime.day.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                              color: Color.fromARGB(255, 11, 11, 11)),
                        ),
                        Text(
                          'Цаг: ${widget.dateTime.hour.toString().padLeft(2, '0')}:${widget.dateTime.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                              color: Color.fromARGB(255, 11, 11, 11)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Нэр',
                    labelStyle: const TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                  ),
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Утас (+976)',
                    labelStyle: const TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                  ),
                  style: const TextStyle(color: Colors.black),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _isLoading
                        ? null
                        : () {
                            setState(() => _isLoading = true);

                            final name = _nameController.text.trim();
                            final phone = _phoneController.text.trim();

                            if (name.isEmpty || phone.length < 8) {
                              setState(() => _isLoading = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Мэдээллээ бүрэн оруулна уу')),
                              );
                              return;
                            }

                            final newBooking = Booking(
                              service: widget.service,
                              dateTime: widget.dateTime,
                              customerName: name,
                              phoneNumber: phone,
                              status: 'pending',
                            );

                            final success =
                                BookingManager.addBooking(newBooking);

                            setState(() => _isLoading = false);

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Захиалга амжилттай нэмэгдлээ!')),
                              );

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookingSuccessPage(
                                    serviceName: widget.service.name,
                                    dateTime: widget.dateTime,
                                    customerName: name,
                                    phone: phone,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Сонгосон цаг аль хэдийн захиалагдсан байна')),
                              );
                            }
                          },
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                                color: Color(0xFF0D47A1)),
                          )
                        : const Text(
                            'Захиалах',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0D47A1)),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
