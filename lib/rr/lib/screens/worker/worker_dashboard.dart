import 'package:flutter/material.dart';

import 'car_list_page.dart';
import 'add_wash_record_page.dart';
import 'wash_queue_page.dart';

class WorkerDashboard extends StatelessWidget {
  final String workerName;
  const WorkerDashboard({super.key, required this.workerName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Worker: $workerName")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text("Машины жагсаалт"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CarListPage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text("Угаалт бүртгэх"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddWashRecordPage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.queue),
              title: const Text("Wash Queue"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WashQueuePage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
