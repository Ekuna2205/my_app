import 'dart:async';
import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class WorkerRequestListPage extends StatefulWidget {
  final String workerName;

  const WorkerRequestListPage({super.key, required this.workerName});

  @override
  State<WorkerRequestListPage> createState() => _WorkerRequestListPageState();
}

class _WorkerRequestListPageState extends State<WorkerRequestListPage> {
  bool loading = true;
  List<Map<String, dynamic>> requests = <Map<String, dynamic>>[];
  Timer? timer;

  @override
  void initState() {
    super.initState();
    loadRequests();

    timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await loadRequests();
    });
  }

  Future<void> loadRequests() async {
    final List<Map<String, dynamic>> data = await DatabaseHelper.instance
        .getPendingWashRequests();

    if (!mounted) return;

    setState(() {
      requests = data;
      loading = false;
    });
  }

  Future<void> acceptRequest(Map<String, dynamic> item) async {
    final int id = ((item['id'] as num?) ?? 0).toInt();

    await DatabaseHelper.instance.updateWashRequestStatus(
      id: id,
      status: 'accepted',
    );

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Хүсэлтийг зөвшөөрлөө')));

    await loadRequests();
  }

  Future<void> rejectRequest(Map<String, dynamic> item) async {
    final int id = ((item['id'] as num?) ?? 0).toInt();

    await DatabaseHelper.instance.updateWashRequestStatus(
      id: id,
      status: 'rejected',
    );

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Хүсэлтийг цуцаллаа')));

    await loadRequests();
  }

  Widget buildRequestCard(Map<String, dynamic> item) {
    final String customerName = item['customerName']?.toString() ?? '';
    final String customerPhone = item['customerPhone']?.toString() ?? '';
    final String carPlate = item['carPlate']?.toString() ?? '';
    final String vehicleType = item['vehicleType']?.toString() ?? '';
    final String note = item['note']?.toString() ?? '';
    final String createdAt = item['createdAt']?.toString() ?? '';

    final String shortDate = createdAt.length >= 16
        ? createdAt.substring(0, 16).replaceFirst('T', ' ')
        : createdAt;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Шинэ хүсэлт',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              customerName.isEmpty ? 'Хэрэглэгч' : customerName,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Утас: $customerPhone'),
            Text('Машины дугаар: $carPlate'),
            Text('Машины төрөл: $vehicleType'),
            Text('Тайлбар: ${note.isEmpty ? 'Байхгүй' : note}'),
            Text('Ирсэн цаг: $shortDate'),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      acceptRequest(item);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Зөвшөөрөх'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      rejectRequest(item);
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Цуцлах'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
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
        title: Text('${widget.workerName} - хүсэлтүүд'),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
          ? const Center(
              child: Text('Шинэ хүсэлт алга', style: TextStyle(fontSize: 18)),
            )
          : RefreshIndicator(
              onRefresh: loadRequests,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: requests.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (BuildContext context, int index) {
                  return buildRequestCard(requests[index]);
                },
              ),
            ),
    );
  }
}
