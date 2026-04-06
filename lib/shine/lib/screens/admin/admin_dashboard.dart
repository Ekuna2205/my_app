import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../services/session_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_background.dart';
import '../../widgets/dashboard_menu_card.dart';
import '../../widgets/stat_card.dart';
import '../login/login_page.dart';
import 'add_worker_page.dart';
import 'admin_booking_list_page.dart';
import 'admin_chart_page.dart';
import 'admin_customer_list.dart';
import 'admin_request_live_page.dart';
import 'payment_report_page.dart';
import 'worker_online_page.dart';
import 'worker_salary_page.dart';
import 'worker_stats_page.dart';
import 'workers_management_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool loading = true;
  int todayIncome = 0;
  int todayCars = 0;
  int onlineWorkers = 0;

  @override
  void initState() {
    super.initState();
    loadSummary();
  }

  Future<void> loadSummary() async {
    final Map<String, int> summary = await DatabaseHelper.instance
        .getTodaySummary();
    final List<Map<String, dynamic>> activeWorkers = await DatabaseHelper
        .instance
        .getActiveWorkers();

    if (!mounted) return;

    setState(() {
      todayIncome = summary['totalIncome'] ?? 0;
      todayCars = summary['totalCars'] ?? 0;
      onlineWorkers = activeWorkers.length;
      loading = false;
    });
  }

  Future<void> logout() async {
    await SessionService.clearSession();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Widget buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Admin Dashboard',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Авто угаалгын газрын нэгдсэн удирдлага',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget buildGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        DashboardMenuCard(
          icon: Icons.people,
          title: 'Хэрэглэгчид',
          subtitle: 'Customer list',
          color: AppColors.primary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminCustomerListPage()),
            ).then((_) => loadSummary());
          },
        ),
        DashboardMenuCard(
          icon: Icons.analytics,
          title: 'Ажилчдын статистик',
          subtitle: 'Worker stats',
          color: AppColors.success,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WorkerStatsPage()),
            ).then((_) => loadSummary());
          },
        ),
        DashboardMenuCard(
          icon: Icons.event,
          title: 'Цагийн захиалгууд',
          subtitle: 'Bookings',
          color: AppColors.warning,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminBookingListPage()),
            ).then((_) => loadSummary());
          },
        ),
        DashboardMenuCard(
          icon: Icons.person_add,
          title: 'Ажилчин бүртгэх',
          subtitle: 'Add worker',
          color: AppColors.info,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddWorkerPage()),
            ).then((_) => loadSummary());
          },
        ),
        DashboardMenuCard(
          icon: Icons.manage_accounts,
          title: 'Ажилчдын жагсаалт',
          subtitle: 'Manage workers',
          color: Colors.purple,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WorkersManagementPage()),
            ).then((_) => loadSummary());
          },
        ),
        DashboardMenuCard(
          icon: Icons.payments_outlined,
          title: 'Цалингийн тооцоо',
          subtitle: 'Salary report',
          color: AppColors.success,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WorkerSalaryPage()),
            ).then((_) => loadSummary());
          },
        ),
        DashboardMenuCard(
          icon: Icons.show_chart,
          title: 'Graph Dashboard',
          subtitle: 'Pro chart',
          color: AppColors.primaryDark,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminChartPage()),
            ).then((_) => loadSummary());
          },
        ),
        DashboardMenuCard(
          icon: Icons.receipt_long,
          title: 'Payment Report',
          subtitle: 'Payments',
          color: AppColors.secondary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PaymentReportPage()),
            ).then((_) => loadSummary());
          },
        ),
        DashboardMenuCard(
          icon: Icons.notifications_active,
          title: 'Live Requests',
          subtitle: 'Realtime requests',
          color: AppColors.danger,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminRequestLivePage()),
            ).then((_) => loadSummary());
          },
        ),
        DashboardMenuCard(
          icon: Icons.circle_notifications,
          title: 'Online / Offline',
          subtitle: 'Worker status',
          color: AppColors.warning,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WorkerOnlinePage()),
            ).then((_) => loadSummary());
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadSummary),
          IconButton(icon: const Icon(Icons.logout), onPressed: logout),
        ],
      ),
      body: AppBackground(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: loadSummary,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    buildHeader(),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        StatCard(
                          icon: Icons.payments,
                          title: 'Өнөөдрийн орлого',
                          value: '$todayIncome₮',
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 10),
                        StatCard(
                          icon: Icons.local_car_wash,
                          title: 'Өнөөдрийн угаалт',
                          value: '$todayCars',
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        StatCard(
                          icon: Icons.circle,
                          title: 'Online worker',
                          value: '$onlineWorkers',
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                    const SizedBox(height: 14),
                    buildGrid(),
                  ],
                ),
              ),
      ),
    );
  }
}
