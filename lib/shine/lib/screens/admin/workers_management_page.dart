import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class WorkersManagementPage extends StatefulWidget {
  const WorkersManagementPage({super.key});

  @override
  State<WorkersManagementPage> createState() => _WorkersManagementPageState();
}

class _WorkersManagementPageState extends State<WorkersManagementPage> {
  bool loading = true;
  List<Map<String, dynamic>> workers = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    loadWorkers();
  }

  Future<void> loadWorkers() async {
    final List<Map<String, dynamic>> data = await DatabaseHelper.instance
        .getWorkers();

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

  Future<void> deleteWorker(int id) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Устгах уу?'),
        content: const Text('Энэ ажилчныг устгахдаа итгэлтэй байна уу?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('Үгүй'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('Тийм'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await DatabaseHelper.instance.deleteWorker(id);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Ажилчин устгагдлаа')));

    await loadWorkers();
  }

  Widget buildWorkerCard(Map<String, dynamic> item, int index) {
    final int id = ((item['id'] as num?) ?? 0).toInt();
    final String fullName = item['fullName']?.toString() ?? '';
    final String username = item['username']?.toString() ?? '';
    final int isActive = ((item['isActive'] as num?) ?? 0).toInt();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                '${index + 1}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Username: $username'),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 12,
                        color: statusColor(isActive),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statusText(isActive),
                        style: TextStyle(
                          color: statusColor(isActive),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                deleteWorker(id);
              },
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
          ],
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ажилчдын жагсаалт'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: loadWorkers, icon: const Icon(Icons.refresh)),
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
                    (int index) => buildWorkerCard(workers[index], index),
                  ),
                ],
              ),
            ),
    );
  }
}
