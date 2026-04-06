import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class WorkerListPage extends StatefulWidget {
  const WorkerListPage({super.key});

  @override
  State<WorkerListPage> createState() => _WorkerListPageState();
}

class _WorkerListPageState extends State<WorkerListPage> {
  List<Map<String, dynamic>> workers = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadWorkers();
  }

  Future<void> loadWorkers() async {
    setState(() => loading = true);

    final data = await DatabaseHelper.instance.getWorkers();

    if (!mounted) return;

    setState(() {
      workers = data;
      loading = false;
    });
  }

  Future<void> deleteWorker(int id) async {
    await DatabaseHelper.instance.deleteWorker(id);
    loadWorkers();
  }

  Future<void> toggleActive(Map<String, dynamic> worker) async {
    final bool isActive = (worker['isActive'] ?? 0) == 1;

    await DatabaseHelper.instance.setWorkerActiveByFullName(
      fullName: worker['fullName'],
      isActive: !isActive,
    );

    loadWorkers();
  }

  Widget buildWorkerCard(Map<String, dynamic> w) {
    final bool isActive = (w['isActive'] ?? 0) == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: isActive
                ? Colors.green.withOpacity(0.15)
                : Colors.grey.shade200,
            child: Icon(
              Icons.person,
              color: isActive ? Colors.green : Colors.grey,
            ),
          ),
          const SizedBox(width: 12),

          /// INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  w['fullName'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "Code: ${w['workerCode'] ?? '-'}",
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                Text(
                  "Username: ${w['username']}",
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),

          /// ACTIVE SWITCH
          Switch(value: isActive, onChanged: (_) => toggleActive(w)),

          /// DELETE
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Устгах уу?'),
                  content: const Text('Энэ ажилчныг устгах уу?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Үгүй'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        deleteWorker(w['id']);
                      },
                      child: const Text('Тийм'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ажилчдын жагсаалт'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadWorkers),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : workers.isEmpty
          ? const Center(child: Text('Ажилчин алга'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: workers.length,
              itemBuilder: (_, i) => buildWorkerCard(workers[i]),
            ),
    );
  }
}
