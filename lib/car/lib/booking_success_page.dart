import 'package:flutter/material.dart';

class BookingSuccessPage extends StatelessWidget {
  final String serviceName;
  final DateTime dateTime;
  final String customerName;
  final String phone;

  const BookingSuccessPage({
    super.key,
    required this.serviceName,
    required this.dateTime,
    required this.customerName,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Амжилттай')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 100, color: Colors.green),
              const SizedBox(height: 24),
              const Text('Захиалга амжилттай боллоо!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              Text('Үйлчилгээ: $serviceName'),
              Text(
                  'Огноо, цаг: ${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}'),
              Text('Нэр: $customerName'),
              Text('Утас: +976 $phone'),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                child: const Text('Нүүр хуудас руу буцах'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
