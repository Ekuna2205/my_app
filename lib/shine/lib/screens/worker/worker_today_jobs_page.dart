import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class WorkerTodayJobsPage extends StatefulWidget {
  final String workerName;

  const WorkerTodayJobsPage({super.key, required this.workerName});

  @override
  State<WorkerTodayJobsPage> createState() => _WorkerTodayJobsPageState();
}

class _WorkerTodayJobsPageState extends State<WorkerTodayJobsPage> {
  List<Map<String, dynamic>> jobs = <Map<String, dynamic>>[];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadJobs();
  }

  Future<void> loadJobs() async {
    final List<Map<String, dynamic>> all = await DatabaseHelper.instance
        .getWashRecords();

    final String today = DateTime.now().toIso8601String().substring(0, 10);

    final List<Map<String, dynamic>> filtered = all.where((item) {
      final String worker = (item['workerName'] ?? '').toString().toLowerCase();
      final String date = (item['date'] ?? '').toString();
      return worker == widget.workerName.toLowerCase() &&
          date.startsWith(today);
    }).toList();

    if (!mounted) {
      return;
    }

    setState(() {
      jobs = filtered;
      loading = false;
    });
  }

  Widget buildJobCard(Map<String, dynamic> item) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.local_car_wash)),
        title: Text(
          item['carNumber']?.toString() ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Төрөл: ${item['washType']}\nҮнэ: ${item['price']}₮"),
        isThreeLine: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Өнөөдрийн ажил"), centerTitle: true),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : jobs.isEmpty
          ? const Center(
              child: Text(
                "Өнөөдөр бүртгэл алга",
                style: TextStyle(fontSize: 18),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.separated(
                itemCount: jobs.length,
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(height: 10);
                },
                itemBuilder: (BuildContext context, int index) {
                  return buildJobCard(jobs[index]);
                },
              ),
            ),
    );
  }
}
