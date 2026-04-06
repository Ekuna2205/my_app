import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class WorkerReportPage extends StatefulWidget {
  const WorkerReportPage({super.key});

  @override
  State<WorkerReportPage> createState() => _WorkerReportPageState();
}

class _WorkerReportPageState extends State<WorkerReportPage> {
  List<Map<String, dynamic>> data = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final result = await DatabaseHelper.instance.getWorkerWashStats();

    if (!mounted) return;

    setState(() {
      data = result;
      loading = false;
    });
  }

  Widget workerCard(Map<String, dynamic> item, int index) {
    final worker = item["workerName"] ?? "";
    final washes = item["totalWashes"] ?? 0;
    final income = item["totalIncome"] ?? 0;

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.blue,
              child: Text(
                "${index + 1}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    worker,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text("🚗 Нийт угаалт: $washes"),

                  Text("💰 Нийт орлого: $income ₮"),
                ],
              ),
            ),

            const Icon(Icons.bar_chart, color: Colors.blue, size: 30),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ажилчдын тайлан"), centerTitle: true),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : data.isEmpty
          ? const Center(
              child: Text("Тайлан байхгүй", style: TextStyle(fontSize: 18)),
            )
          : RefreshIndicator(
              onRefresh: load,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: data.length,
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 10);
                },
                itemBuilder: (context, i) {
                  return workerCard(data[i], i);
                },
              ),
            ),
    );
  }
}
