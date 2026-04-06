import 'package:flutter/material.dart';
import 'worker_register_page.dart';
import 'admin_report_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Угаалга Менежер')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.local_car_wash, size: 40),
              label: const Text('Ажилчин - Машин бүртгэх',
                  style: TextStyle(fontSize: 20)),
              style: ElevatedButton.styleFrom(minimumSize: const Size(280, 80)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WorkerRegisterPage()),
                );
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.dashboard, size: 40),
              label: const Text('Эзэн - Тайлан харах',
                  style: TextStyle(fontSize: 20)),
              style: ElevatedButton.styleFrom(minimumSize: const Size(280, 80)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminReportPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
