import 'package:flutter/material.dart';

class ReceiptPage extends StatelessWidget {
  final int amount;
  final String method;

  const ReceiptPage({super.key, required this.amount, required this.method});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Баримт')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),

            const SizedBox(height: 20),

            const Text(
              'Төлбөр амжилттай!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    row('Дүн', '$amount₮'),
                    row('Арга', method),
                    row('Огноо', DateTime.now().toString().substring(0, 16)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Дуусгах'),
            ),
          ],
        ),
      ),
    );
  }

  Widget row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(title)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
