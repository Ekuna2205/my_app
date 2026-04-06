import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // огноо format-д
import '../../../models/wash_record.dart'; // model-г импорт (доороос үүсгэнэ)

class WashFormScreen extends StatefulWidget {
  const WashFormScreen({super.key});

  @override
  State<WashFormScreen> createState() => _WashFormScreenState();
}

class _WashFormScreenState extends State<WashFormScreen> {
  final _plateController = TextEditingController();
  String? _selectedCarType;
  String? _selectedWashType;
  String? _selectedWorker;

  final List<String> carTypes = ['суудлын', 'жийп', 'микро'];
  final List<String> washTypes = ['гадна', 'дотор', 'бүтэн', 'вакуум'];
  final List<String> workers = [
    'Бат',
    'Сувд',
    'Эрдэнэ',
    'Тэмүүлэн',
  ]; // түр жагсаалт

  double get calculatedPrice {
    if (_selectedCarType == null || _selectedWashType == null) return 0;
    final key = '${_selectedCarType}_${_selectedWashType}';
    const prices = {
      'суудлын_gadna': 15000.0,
      'суудлын_dotor': 20000.0,
      'суудлын_buten': 30000.0,
      'суудлын_vacuum': 5000.0,
      'жийп_gadna': 20000.0,
      'жийп_dotor': 25000.0,
      'жийп_buten': 40000.0,
      'жийп_vacuum': 7000.0,
      'микро_gadna': 25000.0,
      'микро_dotor': 30000.0,
      'микро_buten': 50000.0,
      'микро_vacuum': 10000.0,
    };
    return prices[key] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Шинэ угаалга бүртгэх')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _plateController,
              decoration: const InputDecoration(
                labelText: 'Машины дугаар',
                hintText: 'жишээ: УБА 1234',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedCarType,
              decoration: const InputDecoration(
                labelText: 'Машины төрөл',
                border: OutlineInputBorder(),
              ),
              items: carTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) => setState(() => _selectedCarType = value),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedWashType,
              decoration: const InputDecoration(
                labelText: 'Угаалгын төрөл',
                border: OutlineInputBorder(),
              ),
              items: washTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) => setState(() => _selectedWashType = value),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedWorker,
              decoration: const InputDecoration(
                labelText: 'Ажилчин',
                border: OutlineInputBorder(),
              ),
              items: workers.map((w) {
                return DropdownMenuItem(value: w, child: Text(w));
              }).toList(),
              onChanged: (value) => setState(() => _selectedWorker = value),
            ),
            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Тооцоолсон үнэ: ${NumberFormat.currency(locale: 'mn_MN', symbol: '₮').format(calculatedPrice)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (calculatedPrice == 0)
                      const Text(
                        'Төрлүүдийг сонгоно уу',
                        style: TextStyle(color: Colors.grey),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton.icon(
              onPressed:
                  _selectedCarType != null &&
                      _selectedWashType != null &&
                      _selectedWorker != null &&
                      _plateController.text.trim().isNotEmpty
                  ? _saveWash
                  : null,
              icon: const Icon(Icons.save),
              label: const Text('Хадгалах', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveWash() {
    final newWash = WashRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // түр зуур
      plateNumber: _plateController.text.trim(),
      carType: _selectedCarType!,
      washType: _selectedWashType!,
      workerId: _selectedWorker!,
      startTime: DateTime.now(),
      price: calculatedPrice,
    );

    // Энд Firestore-д хадгалах код орно (дараа нэмнэ)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${newWash.plateNumber} амжилттай бүртгэгдлээ!')),
    );

    Navigator.pop(context); // буцах
  }

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }
}
