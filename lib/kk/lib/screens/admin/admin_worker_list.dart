import 'package:flutter/material.dart';

class AdminWorkerList extends StatelessWidget {
  const AdminWorkerList({super.key});

  @override
  Widget build(BuildContext context) {
    final workers = [
      {"name": "Worker1", "role": "Угаагч"},
      {"name": "Worker2", "role": "Угаагч"},
      {"name": "Admin", "role": "Админ"},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Ажилчид")),
      body: ListView.builder(
        itemCount: workers.length,
        itemBuilder: (context, index) {
          final worker = workers[index];

          return ListTile(
            leading: const Icon(Icons.person),
            title: Text(worker["name"]!),
            subtitle: Text(worker["role"]!),
          );
        },
      ),
    );
  }
}
