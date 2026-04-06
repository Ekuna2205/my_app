import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class WorkerPosPage extends StatefulWidget {
  final String workerName;

  const WorkerPosPage({super.key, required this.workerName});

  @override
  State<WorkerPosPage> createState() => _WorkerPosPageState();
}

class _WorkerPosPageState extends State<WorkerPosPage> {
  final TextEditingController plateController = TextEditingController();

  String selectedCarType = 'Жижиг';

  final List<String> carTypes = [
    'Жижиг',
    'Дунд',
    'Том',
    'Гэр бүлийн',
    'Ачааны',
  ];

  final Map<String, int> servicePrices = {
    'Бүтэн': 40000,
    'Гадар': 30000,
    'Дотор': 30000,
    'Тааз': 30000,
    'Шал': 30000,
  };

  final Set<String> selectedServices = {};

  int get totalPrice {
    int sum = 0;
    for (final s in selectedServices) {
      sum += servicePrices[s] ?? 0;
    }
    return sum;
  }

  void toggleService(String service) {
    setState(() {
      if (selectedServices.contains(service)) {
        selectedServices.remove(service);
      } else {
        selectedServices.add(service);
      }
    });
  }

  Future<void> saveWash() async {
    if (plateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Дугаар оруулна уу')));
      return;
    }

    if (selectedServices.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Угаалгын төрөл сонго')));
      return;
    }

    final washType = '${selectedServices.join(', ')} / $selectedCarType';

    await DatabaseHelper.instance.insertWashRecord({
      'carNumber': plateController.text.trim(),
      'workerName': widget.workerName,
      'washType': washType,
      'price': totalPrice,
      'date': DateTime.now().toIso8601String(),
      'paymentStatus': 'unpaid',
    });

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Амжилттай хадгалагдлаа')));

    setState(() {
      plateController.clear();
      selectedServices.clear();
    });
  }

  Widget buildServiceButton(String service) {
    final bool selected = selectedServices.contains(service);

    return GestureDetector(
      onTap: () => toggleService(service),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.blue),
        ),
        child: Center(
          child: Text(
            service,
            style: TextStyle(
              color: selected ? Colors.white : Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTotalBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.payments, color: Colors.green),
          const SizedBox(width: 10),
          const Expanded(child: Text('Нийт үнэ')),
          Text(
            '$totalPrice₮',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF21CBF3)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Машин угаах (POS)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Ажилчин: ${widget.workerName}',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Угаалт хийх'), centerTitle: true),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            buildHeader(),
            const SizedBox(height: 14),

            /// Машины дугаар
            TextField(
              controller: plateController,
              decoration: InputDecoration(
                labelText: 'Машины дугаар',
                prefixIcon: const Icon(Icons.pin),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// Машины төрөл
            DropdownButtonFormField<String>(
              initialValue: selectedCarType,
              items: carTypes.map((e) {
                return DropdownMenuItem(value: e, child: Text(e));
              }).toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() => selectedCarType = v);
              },
              decoration: InputDecoration(
                labelText: 'Машины төрөл',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 14),

            /// SERVICE GRID
            const Text(
              'Угаалгын төрөл',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: servicePrices.keys
                  .map((s) => buildServiceButton(s))
                  .toList(),
            ),

            const SizedBox(height: 14),

            /// TOTAL
            buildTotalBox(),

            const SizedBox(height: 16),

            /// SAVE BUTTON
            ElevatedButton.icon(
              onPressed: saveWash,
              icon: const Icon(Icons.save),
              label: const Text('Угаалт хадгалах'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
