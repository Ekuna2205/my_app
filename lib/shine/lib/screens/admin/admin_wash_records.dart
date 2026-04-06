import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class AdminWashRecords extends StatefulWidget {
  const AdminWashRecords({super.key});

  @override
  State<AdminWashRecords> createState() => _AdminWashRecordsState();
}

class _AdminWashRecordsState extends State<AdminWashRecords> {
  bool loading = true;
  List<Map<String, dynamic>> records = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    loadRecords();
  }

  Future<void> loadRecords() async {
    final List<Map<String, dynamic>> data = await DatabaseHelper.instance
        .getWashRecords();

    if (!mounted) {
      return;
    }

    setState(() {
      records = data;
      loading = false;
    });
  }

  Widget buildRecordCard(Map<String, dynamic> item) {
    final String workerName = (item['workerName'] ?? '').toString();
    final bool isSelfWash = workerName == 'Customer Self Wash';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isSelfWash
              ? Colors.green.withValues(alpha: 0.12)
              : Colors.blue.withValues(alpha: 0.12),
          child: Icon(
            isSelfWash ? Icons.self_improvement : Icons.local_car_wash,
            color: isSelfWash ? Colors.green : Colors.blue,
          ),
        ),
        title: Text(
          item['carNumber']?.toString() ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Төрөл: ${item['washType']}\n"
          "Хэн: ${isSelfWash ? 'Self Wash' : workerName}\n"
          "Үнэ: ${item['price']}₮\n"
          "Огноо: ${item['date']}",
        ),
        isThreeLine: true,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelfWash
                ? Colors.green.withValues(alpha: 0.10)
                : Colors.orange.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isSelfWash ? "Self" : "Worker",
            style: TextStyle(
              color: isSelfWash ? Colors.green : Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Угаалтын бүртгэл"), centerTitle: true),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : records.isEmpty
          ? const Center(
              child: Text("Бүртгэл алга", style: TextStyle(fontSize: 18)),
            )
          : RefreshIndicator(
              onRefresh: loadRecords,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: records.length,
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(height: 10);
                },
                itemBuilder: (BuildContext context, int index) {
                  return buildRecordCard(records[index]);
                },
              ),
            ),
    );
  }
}
