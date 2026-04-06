import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class WorkerLiveStatusPage extends StatefulWidget {
  const WorkerLiveStatusPage({super.key});

  @override
  State<WorkerLiveStatusPage> createState() => _WorkerLiveStatusPageState();
}

class _WorkerLiveStatusPageState extends State<WorkerLiveStatusPage> {
  List<Map<String, dynamic>> workers = <Map<String, dynamic>>[];
  bool loading = true;

  String get today => DateTime.now().toIso8601String().substring(0, 10);

  @override
  void initState() {
    super.initState();
    loadWorkers();
  }

  Future<void> loadWorkers() async {
    final List<Map<String, dynamic>> data = await DatabaseHelper.instance
        .getWorkersWithLiveStatus(bookingDate: today);

    if (!mounted) return;

    setState(() {
      workers = data;
      loading = false;
    });
  }

  Color statusColor(String status) {
    if (status == 'busy') return Colors.red;
    return Colors.green;
  }

  String statusText(Map<String, dynamic> worker) {
    final String status = worker['liveStatus']?.toString() ?? 'free';

    if (status == 'busy') {
      final String until = worker['busyUntil']?.toString() ?? '';
      final String customer = worker['currentCustomer']?.toString() ?? '';
      final String plate = worker['currentPlate']?.toString() ?? '';
      return '🔴 Ажиллаж байна\n⏰ $until хүртэл\n👤 $customer\n🚗 $plate';
    }

    return '🟢 Сул';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ажилчдын live төлөв'),
        actions: [
          IconButton(onPressed: loadWorkers, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadWorkers,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: workers.length,
                itemBuilder: (context, index) {
                  final worker = workers[index];
                  final String code = worker['workerCode']?.toString() ?? 'N/A';
                  final String name = worker['fullName']?.toString() ?? '-';
                  final String status =
                      worker['liveStatus']?.toString() ?? 'free';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: statusColor(status),
                          child: const Icon(
                            Icons.engineering,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$code - $name',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(statusText(worker)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
