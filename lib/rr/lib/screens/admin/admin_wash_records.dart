import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class AdminWashRecords extends StatefulWidget {
  const AdminWashRecords({super.key});

  @override
  State<AdminWashRecords> createState() => _AdminWashRecordsState();
}

class _AdminWashRecordsState extends State<AdminWashRecords> {
  List<Map<String, dynamic>> records = [];

  @override
  void initState() {
    super.initState();
    loadRecords();
  }

  Future<void> loadRecords() async {
    final data = await DatabaseHelper.instance.getWashRecords();
    setState(() => records = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Угаалгын бүртгэл")),
      body: ListView.builder(
        itemCount: records.length,
        itemBuilder: (context, index) {
          final r = records[index];
          return ListTile(
            title: Text(r['carNumber'] ?? ''),
            subtitle: Text("${r['workerName'] ?? ''} • ${r['washType'] ?? ''}"),
            trailing: Text("${r['price'] ?? 0}₮"),
          );
        },
      ),
    );
  }
}
