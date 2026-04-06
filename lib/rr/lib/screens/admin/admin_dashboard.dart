import 'package:flutter/material.dart';

import '../../widgets/app_background.dart';

import 'admin_car_list.dart';
import 'admin_worker_list.dart';
import 'admin_wash_records.dart';
import 'admin_daily_report.dart';
import 'admin_income_dashboard.dart';
import 'admin_price_page.dart';

import '../worker/wash_queue_page.dart';
import '../customer/customer_price_page.dart';

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
        elevation: 8,
        shadowColor: Colors.black26,
        color: Colors.white.withValues(alpha: 0.92),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 38, color: Colors.blue.shade700),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
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
      body: AppBackground(
        title: "Admin",
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              buildCard(
                context,
                Icons.receipt_long,
                "Өдрийн\nтайлан",
                const AdminDailyReport(),
              ),
              buildCard(
                context,
                Icons.local_car_wash,
                "Угаалтын\nбүртгэл",
                const AdminWashRecords(),
              ),
              buildCard(
                context,
                Icons.directions_car,
                "Машины\nжагсаалт",
                const AdminCarList(),
              ),
              buildCard(
                context,
                Icons.people,
                "Ажилчид",
                const AdminWorkerList(),
              ),
              buildCard(
                context,
                Icons.payments,
                "Орлогын\nDashboard",
                const AdminIncomeDashboard(),
              ),
              buildCard(
                context,
                Icons.queue,
                "Wash\nQueue",
                const WashQueuePage(),
              ),
              buildCard(
                context,
                Icons.attach_money,
                "Үнэ\nтохируулах",
                const AdminPricePage(),
              ),
              buildCard(
                context,
                Icons.qr_code,
                "Customer\nҮнэ харах",
                const CustomerPricePage(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
