import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class WorkerSalaryPage extends StatefulWidget {
  const WorkerSalaryPage({super.key});

  @override
  State<WorkerSalaryPage> createState() => _WorkerSalaryPageState();
}

class _WorkerSalaryPageState extends State<WorkerSalaryPage> {
  bool loading = true;
  List<Map<String, dynamic>> workers = [];

  @override
  void initState() {
    super.initState();
    loadWorkers();
  }

  Future<void> loadWorkers() async {
    final result = await DatabaseHelper.instance.getWorkerSalaryReport();

    if (!mounted) return;

    setState(() {
      workers = result;
      loading = false;
    });
  }

  Widget buildWorkerCard(Map<String, dynamic> worker) {
    final name = worker["workerName"];
    final totalWashes = worker["totalWashes"];
    final totalIncome = worker["totalIncome"];
    final salary = worker["salary"];

    return Card(
      elevation: 4,
      child: ListTile(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),

        subtitle: Text("Угаасан машин: $totalWashes\nОрлого: $totalIncome₮"),

        trailing: Text(
          "$salary₮",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ажилчны цалин"), centerTitle: true),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : workers.isEmpty
          ? const Center(child: Text("Ажилчин байхгүй"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: workers.length,
              itemBuilder: (context, index) {
                return buildWorkerCard(workers[index]);
              },
            ),
    );
  }
}
