import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class AdminRequestPage extends StatefulWidget {
  const AdminRequestPage({super.key});

  @override
  State<AdminRequestPage> createState() => _AdminRequestPageState();
}

class _AdminRequestPageState extends State<AdminRequestPage> {
  List<Map<String, dynamic>> requests = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final data = await DatabaseHelper.instance.getPendingWashRequests();

    if (!mounted) return;

    setState(() {
      requests = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Requests')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: requests.map((e) {
          return Card(
            child: ListTile(
              title: Text(e['carPlate']),
              subtitle: Text(e['vehicleType']),
              trailing: Text(e['status']),
            ),
          );
        }).toList(),
      ),
    );
  }
}
