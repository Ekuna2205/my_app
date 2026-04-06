import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import 'worker_detail_page.dart';

class WorkerStatsPage extends StatefulWidget {
  const WorkerStatsPage({super.key});

  @override
  State<WorkerStatsPage> createState() => _WorkerStatsPageState();
}

class _WorkerStatsPageState extends State<WorkerStatsPage> {
  bool loading = true;
  List<Map<String, dynamic>> stats = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    final List<Map<String, dynamic>> data = await DatabaseHelper.instance
        .getWorkerWashStats();

    if (!mounted) {
      return;
    }

    setState(() {
      stats = data;
      loading = false;
    });
  }

  int getTotalWashes() {
    int sum = 0;
    for (final Map<String, dynamic> item in stats) {
      sum += ((item['totalWashes'] as num?) ?? 0).toInt();
    }
    return sum;
  }

  int getTotalIncome() {
    int sum = 0;
    for (final Map<String, dynamic> item in stats) {
      sum += ((item['totalIncome'] as num?) ?? 0).toInt();
    }
    return sum;
  }

  Widget summaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCard(Map<String, dynamic> item, int index) {
    final String workerName = item['workerName']?.toString() ?? '';
    final int totalWashes = ((item['totalWashes'] as num?) ?? 0).toInt();
    final int totalIncome = ((item['totalIncome'] as num?) ?? 0).toInt();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WorkerDetailPage(workerName: workerName),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            '${index + 1}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          workerName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Нийт угаалт: $totalWashes\nНийт орлого: $totalIncome₮'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        isThreeLine: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ажилчдын статистик'),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : stats.isEmpty
          ? const Center(
              child: Text('Статистик алга', style: TextStyle(fontSize: 18)),
            )
          : RefreshIndicator(
              onRefresh: loadStats,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      summaryCard(
                        icon: Icons.local_car_wash,
                        title: 'Нийт угаалт',
                        value: '${getTotalWashes()}',
                        color: Colors.blue,
                      ),
                      summaryCard(
                        icon: Icons.payments,
                        title: 'Нийт орлого',
                        value: '${getTotalIncome()}₮',
                        color: Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(
                    stats.length,
                    (int index) => buildCard(stats[index], index),
                  ),
                ],
              ),
            ),
    );
  }
}
