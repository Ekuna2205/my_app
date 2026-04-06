import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class AdminDailyReport extends StatefulWidget {
  const AdminDailyReport({super.key});

  @override
  State<AdminDailyReport> createState() => _AdminDailyReportState();
}

class _AdminDailyReportState extends State<AdminDailyReport> {
  bool loading = true;

  int totalIncome = 0;
  int totalCars = 0;
  int workerWashCount = 0;
  int selfWashCount = 0;
  int workerIncome = 0;
  int selfWashIncome = 0;

  @override
  void initState() {
    super.initState();
    loadReport();
  }

  Future<void> loadReport() async {
    final List<Map<String, dynamic>> records = await DatabaseHelper.instance
        .getWashRecords();

    final String today = DateTime.now().toIso8601String().substring(0, 10);

    int tIncome = 0;
    int tCars = 0;
    int wCount = 0;
    int sCount = 0;
    int wIncome = 0;
    int sIncome = 0;

    for (final Map<String, dynamic> item in records) {
      final String date = (item['date'] ?? '').toString();
      if (!date.startsWith(today)) {
        continue;
      }

      final String workerName = (item['workerName'] ?? '').toString();
      final int price = (item['price'] as int?) ?? 0;

      tCars++;
      tIncome += price;

      if (workerName == 'Customer Self Wash') {
        sCount++;
        sIncome += price;
      } else {
        wCount++;
        wIncome += price;
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      totalIncome = tIncome;
      totalCars = tCars;
      workerWashCount = wCount;
      selfWashCount = sCount;
      workerIncome = wIncome;
      selfWashIncome = sIncome;
      loading = false;
    });
  }

  Widget buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Өдрийн тайлан"), centerTitle: true),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                buildInfoCard(
                  title: "Нийт орлого",
                  value: "$totalIncome₮",
                  icon: Icons.payments,
                  color: Colors.green,
                ),
                const SizedBox(height: 12),
                buildInfoCard(
                  title: "Нийт машин",
                  value: "$totalCars",
                  icon: Icons.directions_car,
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),
                buildInfoCard(
                  title: "Ажилтан угаасан машин",
                  value: "$workerWashCount",
                  icon: Icons.local_car_wash,
                  color: Colors.orange,
                ),
                const SizedBox(height: 12),
                buildInfoCard(
                  title: "Өөрөө угаасан машин",
                  value: "$selfWashCount",
                  icon: Icons.self_improvement,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 12),
                buildInfoCard(
                  title: "Ажилтны угаалтын орлого",
                  value: "$workerIncome₮",
                  icon: Icons.badge,
                  color: Colors.teal,
                ),
                const SizedBox(height: 12),
                buildInfoCard(
                  title: "Self wash орлого",
                  value: "$selfWashIncome₮",
                  icon: Icons.person,
                  color: Colors.pink,
                ),
              ],
            ),
    );
  }
}
