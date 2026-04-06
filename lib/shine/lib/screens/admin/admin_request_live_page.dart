import 'dart:async';
import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class AdminRequestLivePage extends StatefulWidget {
  const AdminRequestLivePage({super.key});

  @override
  State<AdminRequestLivePage> createState() => _AdminRequestLivePageState();
}

class _AdminRequestLivePageState extends State<AdminRequestLivePage> {
  List<Map<String, dynamic>> requests = [];
  bool loading = true;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    load();

    // 🔥 3 секунд тутам шинэчлэнэ
    timer = Timer.periodic(const Duration(seconds: 3), (_) {
      load();
    });
  }

  Future<void> load() async {
    final data = await DatabaseHelper.instance.getPendingWashRequests();

    if (!mounted) return;

    setState(() {
      requests = data;
      loading = false;
    });
  }

  Color statusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String statusText(String status) {
    switch (status) {
      case 'accepted':
        return 'Зөвшөөрсөн';
      case 'rejected':
        return 'Цуцалсан';
      default:
        return 'Хүлээгдэж байна';
    }
  }

  Widget buildCard(Map<String, dynamic> item) {
    final String carPlate = item['carPlate'] ?? '';
    final String phone = item['customerPhone'] ?? '';
    final String type = item['vehicleType'] ?? '';
    final String note = item['note'] ?? '';
    final String status = item['status'] ?? 'pending';
    final String time = item['createdAt'] ?? '';

    final String shortTime = time.length >= 16
        ? time.substring(0, 16).replaceFirst('T', ' ')
        : time;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // статус badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor(status).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusText(status),
                style: TextStyle(
                  color: statusColor(status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              carPlate,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text('Утас: $phone'),
            Text('Төрөл: $type'),
            Text('Тайлбар: ${note.isEmpty ? "байхгүй" : note}'),
            Text('Цаг: $shortTime'),
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
      appBar: AppBar(title: const Text('Live Requests'), centerTitle: true),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
          ? const Center(
              child: Text('Хүсэлт алга', style: TextStyle(fontSize: 18)),
            )
          : RefreshIndicator(
              onRefresh: load,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: requests.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return buildCard(requests[index]);
                },
              ),
            ),
    );
  }
}
