import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class CustomerSelfWashPage extends StatefulWidget {
  const CustomerSelfWashPage({super.key});

  @override
  State<CustomerSelfWashPage> createState() => _CustomerSelfWashPageState();
}

class _CustomerSelfWashPageState extends State<CustomerSelfWashPage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final plateController = TextEditingController();

  String selectedTime = "10:00";

  Future<void> save() async {
    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        plateController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Мэдээлэл дутуу")));
      return;
    }

    await DatabaseHelper.instance.createBooking(
      customerName: nameController.text,
      phone: phoneController.text,
      carPlate: plateController.text,
      bookingDate: DateTime.now().toIso8601String().substring(0, 10),
      bookingTime: selectedTime,
      serviceType: "Өөрөө угаах",

      // 🔥 чухал
      workerId: -1,
      workerName: "Self Wash",
    );

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Амжилттай")));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Өөрөө угаах")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Нэр"),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Утас"),
            ),
            TextField(
              controller: plateController,
              decoration: const InputDecoration(labelText: "Дугаар"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: save, child: const Text("Эхлүүлэх")),
          ],
        ),
      ),
    );
  }
}
