import 'package:flutter/material.dart';

import 'admin_car_list.dart';
import 'admin_worker_list.dart';
import 'admin_wash_records.dart';
import 'admin_daily_report.dart';
import 'admin_income_dashboard.dart';

import '../worker/wash_queue_page.dart';
import '../customer/customer_price_qr.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  Widget buildCard(
    BuildContext context,
    IconData icon,
    String title,
    Widget page,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.blue),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard"), centerTitle: true),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,

          children: [
            /// Өдрийн тайлан
            buildCard(
              context,
              Icons.receipt_long,
              "Өдрийн тайлан",
              const AdminDailyReport(),
            ),

            /// Угаалтын бүртгэл
            buildCard(
              context,
              Icons.local_car_wash,
              "Угаалтын бүртгэл",
              const AdminWashRecords(),
            ),

            /// Машины жагсаалт
            buildCard(
              context,
              Icons.directions_car,
              "Машины жагсаалт",
              const AdminCarList(),
            ),

            /// Ажилчид
            buildCard(
              context,
              Icons.people,
              "Ажилчид",
              const AdminWorkerList(),
            ),

            /// 💰 Орлогын Dashboard
            buildCard(
              context,
              Icons.payments,
              "Орлогын\nDashboard",
              const AdminIncomeDashboard(),
            ),

            /// 🚿 Wash Queue
            buildCard(
              context,
              Icons.queue,
              "Wash Queue",
              const WashQueuePage(),
            ),

            /// 📱 Customer QR
            buildCard(
              context,
              Icons.qr_code,
              "Customer\nҮнэ харах",
              const CustomerPriceQrPage(),
            ),
          ],
        ),
      ),
    );
  }
}
