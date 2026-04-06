import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class AddWashRecordPage extends StatefulWidget {
  const AddWashRecordPage({super.key});

  @override
  State<AddWashRecordPage> createState() => _AddWashRecordPageState();
}

class _AddWashRecordPageState extends State<AddWashRecordPage> {
  final TextEditingController plateController = TextEditingController();

  String washType = "Гадна";
  String workerName = "Worker1";

  @override
  void dispose() {
    plateController.dispose();
    super.dispose();
  }

  int _calcPrice(String type) {
    switch (type) {
      case "Гадна":
        return 10000;
      case "Дотор":
        return 12000;
      case "Бүтэн":
        return 18000;
      case "Вакум":
        return 5000;
      default:
        return 0;
    }
  }

  Future<void> saveRecord() async {
    final price = _calcPrice(washType);

    await DatabaseHelper.instance.insertWashRecord({
      "carNumber": plateController.text.trim(),
      "workerName": workerName,
      "washType": washType,
      "price": price,
      "date": DateTime.now().toString(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Бүртгэгдлээ ✅ Үнэ: $price₮")));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final price = _calcPrice(washType);

    return Scaffold(
      appBar: AppBar(title: const Text("Угаалт бүртгэх")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: plateController,
              decoration: const InputDecoration(labelText: "Машины дугаар"),
            ),
            const SizedBox(height: 12),

            // ✅ value биш initialValue ашиглана
            DropdownButtonFormField<String>(
              initialValue: washType,
              items: const [
                DropdownMenuItem(value: "Гадна", child: Text("Гадна")),
                DropdownMenuItem(value: "Дотор", child: Text("Дотор")),
                DropdownMenuItem(value: "Бүтэн", child: Text("Бүтэн")),
                DropdownMenuItem(value: "Вакум", child: Text("Вакум")),
              ],
              onChanged: (v) {
                setState(() {
                  washType = v ?? "Гадна";
                });
              },
              decoration: const InputDecoration(labelText: "Угаалгын төрөл"),
            ),

            const SizedBox(height: 12),
            Text("Автомат үнэ: $price₮", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: saveRecord,
              child: const Text("Хадгалах"),
            ),
          ],
        ),
      ),
    );
  }
}
