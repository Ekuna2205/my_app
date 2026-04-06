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

  Color statusColor(String status) {
    return status == 'paid' ? Colors.green : Colors.red;
  }

  String statusText(String status) {
    return status == 'paid' ? 'Төлсөн' : 'Төлөөгүй';
  }

  Widget buildCarCard(Map<String, dynamic> item, int index) {
    final String carNumber = item['carNumber']?.toString() ?? '';
    final String washType = item['washType']?.toString() ?? '';
    final int price = ((item['price'] as num?) ?? 0).toInt();
    final String date = item['date']?.toString() ?? '';
    final String paymentStatus = item['paymentStatus']?.toString() ?? 'unpaid';

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
        subtitle: Text(
          'Үйлчилгээ: $washType\nҮнэ: $price₮\nТөлөв: ${statusText(paymentStatus)}',
        ),
        trailing: SizedBox(
          width: 95,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                shortDate,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              Text(
                statusText(paymentStatus),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: statusColor(paymentStatus),
                ),
              ),
            ],
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

  int totalPaid() {
    int sum = 0;
    for (final Map<String, dynamic> item in cars) {
      if ((item['paymentStatus']?.toString() ?? 'unpaid') == 'paid') {
        sum += ((item['price'] as num?) ?? 0).toInt();
      }
    }
    return sum;
  }

  int totalUnpaid() {
    int sum = 0;
    for (final Map<String, dynamic> item in cars) {
      if ((item['paymentStatus']?.toString() ?? 'unpaid') != 'paid') {
        sum += ((item['price'] as num?) ?? 0).toInt();
      }
    }
    return sum;
  }

  Widget summaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        trailing: Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: color,
          ),
        ),
      ),
    );
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
                  summaryCard(
                    icon: Icons.payments,
                    title: 'Нийт орлого',
                    value: '${totalIncome()}₮',
                    color: Colors.blue,
                  ),
                  summaryCard(
                    icon: Icons.check_circle,
                    title: 'Төлсөн дүн',
                    value: '${totalPaid()}₮',
                    color: Colors.green,
                  ),
                  summaryCard(
                    icon: Icons.error,
                    title: 'Төлөөгүй дүн',
                    value: '${totalUnpaid()}₮',
                    color: Colors.red,
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
