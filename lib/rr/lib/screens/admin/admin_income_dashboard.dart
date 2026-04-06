import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import 'admin_income_chart.dart';

class AdminIncomeDashboard extends StatefulWidget {
  const AdminIncomeDashboard({super.key});

  @override
  State<AdminIncomeDashboard> createState() => _AdminIncomeDashboardState();
}

class _AdminIncomeDashboardState extends State<AdminIncomeDashboard> {
  int total = 0;
  int count = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final summary = await DatabaseHelper.instance.getTodaySummary();
    setState(() {
      total = summary['total'] ?? 0;
      count = summary['count'] ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Орлогын Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.payments),
                title: Text("Өнөөдрийн орлого: $total₮"),
                subtitle: Text("Нийт угаасан машин: $count"),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.bar_chart),
              label: const Text("Сүүлийн 7 хоногийн график"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminIncomeChart()),
                );
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("Шинэчлэх"),
              onPressed: _load,
            ),
          ],
        ),
      ),
    );
  }
}
