import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class WorkerDetailPage extends StatefulWidget {
  final String workerName;

  const WorkerDetailPage({super.key, required this.workerName});

  @override
  State<WorkerDetailPage> createState() => _WorkerDetailPageState();
}

class _WorkerDetailPageState extends State<WorkerDetailPage> {
  bool loading = true;
  List<Map<String, dynamic>> cars = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    loadCars();
  }

  Future<void> loadCars() async {
    final List<Map<String, dynamic>> data = await DatabaseHelper.instance
        .getWorkerCars(widget.workerName);

    if (!mounted) return;

    setState(() {
      cars = data;
      loading = false;
    });
  }

  Widget buildCarCard(Map<String, dynamic> item, int index) {
    final String carNumber = item['carNumber']?.toString() ?? '';
    final String washType = item['washType']?.toString() ?? '';
    final int price = ((item['price'] as num?) ?? 0).toInt();
    final String date = item['date']?.toString() ?? '';

    final String shortDate = date.length >= 16
        ? date.substring(0, 16).replaceFirst('T', ' ')
        : date;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            '${index + 1}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          carNumber,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Үйлчилгээ: $washType\nҮнэ: $price₮'),
        trailing: SizedBox(
          width: 95,
          child: Text(
            shortDate,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        isThreeLine: true,
      ),
    );
  }

  int totalIncome() {
    int sum = 0;
    for (final Map<String, dynamic> item in cars) {
      sum += ((item['price'] as num?) ?? 0).toInt();
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.workerName} - дэлгэрэнгүй'),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : cars.isEmpty
          ? const Center(
              child: Text(
                'Угаасан машины мэдээлэл алга',
                style: TextStyle(fontSize: 18),
              ),
            )
          : RefreshIndicator(
              onRefresh: loadCars,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.payments, color: Colors.green),
                      title: const Text('Нийт орлого'),
                      trailing: Text(
                        '${totalIncome()}₮',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.local_car_wash),
                      title: const Text('Нийт угаасан машин'),
                      trailing: Text(
                        '${cars.length}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(
                    cars.length,
                    (int index) => buildCarCard(cars[index], index),
                  ),
                ],
              ),
            ),
    );
  }
}
