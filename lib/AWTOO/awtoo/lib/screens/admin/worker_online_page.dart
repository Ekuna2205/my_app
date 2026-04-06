import 'dart:async';
import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class WorkerOnlinePage extends StatefulWidget {
  const WorkerOnlinePage({super.key});

  @override
  State<WorkerOnlinePage> createState() => _WorkerOnlinePageState();
}

class _WorkerOnlinePageState extends State<WorkerOnlinePage> {
  bool loading = true;
  List<Map<String, dynamic>> workers = <Map<String, dynamic>>[];
  Timer? timer;

  @override
  void initState() {
    super.initState();
    loadWorkers();

    // 🔥 realtime refresh (3 sec)
    timer = Timer.periodic(const Duration(seconds: 3), (_) {
      loadWorkers();
    });
  }

  Future<void> loadWorkers() async {
    final data = await DatabaseHelper.instance.getWorkerOnlineStatus();

    if (!mounted) return;

    setState(() {
      workers = data;
      loading = false;
    });
  }

  Color statusColor(int isActive) {
    return isActive == 1 ? Colors.green : Colors.grey;
  }

  String statusText(int isActive) {
    return isActive == 1 ? 'Online' : 'Offline';
  }

  Widget buildWorkerCard(Map<String, dynamic> item, int index) {
    final String name = item['fullName']?.toString() ?? '';
    final String username = item['username']?.toString() ?? '';
    final int isActive = ((item['isActive'] as num?) ?? 0).toInt();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor(isActive).withValues(alpha: 0.15),
          child: Icon(Icons.person, color: statusColor(isActive)),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Username: $username'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor(isActive).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            statusText(isActive),
            style: TextStyle(
              color: statusColor(isActive),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget summaryCard() {
    final int total = workers.length;
    final int online = workers.where((e) {
      return ((e['isActive'] as num?) ?? 0).toInt() == 1;
    }).length;

    final int offline = total - online;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const Text('Нийт'),
                const SizedBox(height: 6),
                Text(
                  '$total',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                const Text('Online'),
                const SizedBox(height: 6),
                Text(
                  '$online',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                const Text('Offline'),
                const SizedBox(height: 6),
                Text(
                  '$offline',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ажилчдын төлөв'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadWorkers),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : workers.isEmpty
          ? const Center(
              child: Text('Ажилчин алга', style: TextStyle(fontSize: 18)),
            )
          : RefreshIndicator(
              onRefresh: loadWorkers,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  summaryCard(),
                  const SizedBox(height: 12),
                  ...List.generate(
                    workers.length,
                    (index) => buildWorkerCard(workers[index], index),
                  ),
                ],
              ),
            ),
    );
  }
}
