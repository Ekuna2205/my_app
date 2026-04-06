import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class AdminDailyReport extends StatefulWidget {
  const AdminDailyReport({super.key});

  @override
  State<AdminDailyReport> createState() => _AdminDailyReportState();
}

class _AdminDailyReportState extends State<AdminDailyReport> {
  List<Map<String, dynamic>> records = [];
  int totalIncome = 0;

  @override
  void initState() {
    super.initState();
    loadReport();
  }

  Future<void> loadReport() async {
    final data = await DatabaseHelper.instance.getWashRecords();

    int income = 0;

    for (var r in data) {
      income += (r["price"] ?? 0) as int;
    }

    setState(() {
      records = data;
      totalIncome = income;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Өдрийн тайлан")),

      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              children: [
                Text(
                  "Нийт угаалт: ${records.length}",
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  "Нийт орлого: $totalIncome ₮",
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, index) {
                final r = records[index];

                return ListTile(
                  leading: const Icon(Icons.local_car_wash),
                  title: Text(r["carNumber"] ?? ""),
                  subtitle: Text("${r["workerName"]} | ${r["washType"]}"),
                  trailing: Text("${r["price"]}₮"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
