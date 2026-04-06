import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class WorkerIncomePage extends StatefulWidget {
  final String workerName;

  const WorkerIncomePage({super.key, required this.workerName});

  @override
  State<WorkerIncomePage> createState() => _WorkerIncomePageState();
}

class _WorkerIncomePageState extends State<WorkerIncomePage> {
  int totalIncome = 0;
  int totalCount = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadIncome();
  }

  Future<void> loadIncome() async {
    final List<Map<String, dynamic>> all = await DatabaseHelper.instance
        .getWashRecords();

    final String today = DateTime.now().toIso8601String().substring(0, 10);

    int income = 0;
    int count = 0;

    for (final Map<String, dynamic> item in all) {
      final String worker = (item['workerName'] ?? '').toString().toLowerCase();
      final String date = (item['date'] ?? '').toString();

      if (worker == widget.workerName.toLowerCase() && date.startsWith(today)) {
        income += (item['price'] as int?) ?? 0;
        count++;
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      totalIncome = income;
      totalCount = count;
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.16),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
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
      appBar: AppBar(title: const Text("Өдрийн орлого"), centerTitle: true),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  buildInfoCard(
                    title: "Ажилчин",
                    value: widget.workerName,
                    icon: Icons.badge,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  buildInfoCard(
                    title: "Өнөөдөр угаасан машин",
                    value: "$totalCount",
                    icon: Icons.directions_car,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  buildInfoCard(
                    title: "Өнөөдрийн орлого",
                    value: "$totalIncome₮",
                    icon: Icons.payments,
                    color: Colors.green,
                  ),
                ],
              ),
            ),
    );
  }
}
