import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class PaymentPage extends StatefulWidget {
  final int amount;
  final int recordId;

  const PaymentPage({super.key, required this.amount, required this.recordId});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool loading = false;

  Future<void> pay() async {
    setState(() {
      loading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    await DatabaseHelper.instance.markAsPaid(widget.recordId);

    if (!mounted) return;

    setState(() {
      loading = false;
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Амжилттай'),
        content: const Text('Төлбөр амжилттай төлөгдлөө'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget qrBox() {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: const Icon(Icons.qr_code_2, size: 120, color: Colors.black),
    );
  }

  Widget infoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const Text(
              'QPay / Demo Payment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            Text(
              '${widget.amount}₮',
              style: const TextStyle(
                fontSize: 32,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Энэ бол demo төлбөрийн дэлгэц.\nТөлөх товч дарснаар төлбөр хийгдсэн гэж бүртгэнэ.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Төлбөр'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            infoCard(),
            const SizedBox(height: 24),
            qrBox(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: loading ? null : pay,
                icon: const Icon(Icons.payments),
                label: loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Төлөх'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
