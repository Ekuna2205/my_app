import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class AdminIncomeDashboard extends StatefulWidget {
  const AdminIncomeDashboard({super.key});

  @override
  State<AdminIncomeDashboard> createState() => _AdminIncomeDashboardState();
}

class _AdminIncomeDashboardState extends State<AdminIncomeDashboard> {
  bool loading = true;

  int totalIncome = 0;
  int workerIncome = 0;
  int selfWashIncome = 0;
  int workerCount = 0;
  int selfWashCount = 0;

  @override
  void initState() {
    super.initState();
    loadIncome();
  }

  Future<void> loadIncome() async {
    final List<Map<String, dynamic>> records = await DatabaseHelper.instance
        .getWashRecords();

    final String today = DateTime.now().toIso8601String().substring(0, 10);

    int total = 0;
    int workerTotal = 0;
    int selfTotal = 0;
    int wCount = 0;
    int sCount = 0;

    for (final Map<String, dynamic> item in records) {
      final String date = (item['date'] ?? '').toString();
      if (!date.startsWith(today)) {
        continue;
      }

      final String workerName = (item['workerName'] ?? '').toString();
      final int price = (item['price'] as int?) ?? 0;

      total += price;

      if (workerName == 'Customer Self Wash') {
        selfTotal += price;
        sCount++;
      } else {
        workerTotal += price;
        wCount++;
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      totalIncome = total;
      workerIncome = workerTotal;
      selfWashIncome = selfTotal;
      workerCount = wCount;
      selfWashCount = sCount;
      loading = false;
    });
  }

  Widget buildIncomeCard({
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
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
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCountCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 0),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Орлогын dashboard"), centerTitle: true),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                buildIncomeCard(
                  title: "Нийт орлого",
                  value: "$totalIncome₮",
                  icon: Icons.account_balance_wallet,
                  color: Colors.green,
                ),
                const SizedBox(height: 12),
                buildIncomeCard(
                  title: "Ажилтны угаалтын орлого",
                  value: "$workerIncome₮",
                  icon: Icons.badge,
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),
                buildIncomeCard(
                  title: "Self wash орлого",
                  value: "$selfWashIncome₮",
                  icon: Icons.self_improvement,
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    buildCountCard(
                      title: "Worker wash",
                      value: "$workerCount",
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    buildCountCard(
                      title: "Self wash",
                      value: "$selfWashCount",
                      color: Colors.orange,
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
