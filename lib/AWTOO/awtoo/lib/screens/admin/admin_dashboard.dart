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
  int paidCount = 0;
  int unpaidCount = 0;
  int pendingRequests = 0;

  Map<String, dynamic> topWorker = <String, dynamic>{
    'workerName': '-',
    'workerCode': 'N/A',
    'totalWashes': 0,
    'totalIncome': 0,
  };

  List<Map<String, dynamic>> recentBookings = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    loadSummary();
  }

  Future<void> loadSummary() async {
    setState(() => loading = true);

    final Map<String, int> summary = await DatabaseHelper.instance
        .getTodaySummary();

    final List<Map<String, dynamic>> activeWorkers = await DatabaseHelper
        .instance
        .getActiveWorkers();

    final Map<String, int> payment = await DatabaseHelper.instance
        .getPaymentStats();

    final int pending = await DatabaseHelper.instance.getPendingRequestCount();

    final Map<String, dynamic> top = await DatabaseHelper.instance
        .getTopWorkerToday();

    final String topCode = await DatabaseHelper.instance.getWorkerCodeByName(
      top['workerName']?.toString() ?? '',
    );

    final List<Map<String, dynamic>> bookings = await DatabaseHelper.instance
        .getAllBookings();

    final List<Map<String, dynamic>> recent = List<Map<String, dynamic>>.from(
      bookings.take(5),
    );

    for (final Map<String, dynamic> booking in recent) {
      final String workerName = booking['workerName']?.toString() ?? '';
      bookings.take(5).map((e) => Map<String, dynamic>.from(e)).toList();
    }

    if (!mounted) return;

    setState(() {
      todayIncome = summary['totalIncome'] ?? 0;
      todayCars = summary['totalCars'] ?? 0;
      onlineWorkers = activeWorkers.length;
      paidCount = payment['paid'] ?? 0;
      unpaidCount = payment['unpaid'] ?? 0;
      pendingRequests = pending;
      topWorker = <String, dynamic>{...top, 'workerCode': topCode};
      recentBookings = recent;
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

  String formatMoney(num value) => '${value.toInt()}₮';

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
            'Админ',
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

  Widget buildSummaryCards() {
    return Row(
      children: [
        StatCard(
          icon: Icons.payments,
          title: 'Өнөөдрийн орлого',
          value: formatMoney(todayIncome),
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
    );
  }

  Widget buildSecondaryStats() {
    return Column(
      children: [
        Row(
          children: [
            StatCard(
              icon: Icons.circle,
              title: 'Online worker',
              value: '$onlineWorkers',
              color: AppColors.warning,
            ),
            const SizedBox(width: 10),
            StatCard(
              icon: Icons.assignment_late,
              title: 'Хүсэлтүүд',
              value: '$pendingRequests',
              color: AppColors.danger,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            StatCard(
              icon: Icons.check_circle,
              title: 'Төлсөн',
              value: '$paidCount',
              color: AppColors.success,
            ),
            const SizedBox(width: 10),
            StatCard(
              icon: Icons.error,
              title: 'Төлөөгүй',
              value: '$unpaidCount',
              color: AppColors.danger,
            ),
          ],
        ),
      ],
    );
  }

  Widget buildTopWorkerCard() {
    final String workerName = topWorker['workerName']?.toString() ?? '-';
    final String workerCode = topWorker['workerCode']?.toString() ?? 'N/A';
    final int washes = ((topWorker['totalWashes'] as num?) ?? 0).toInt();
    final int income = ((topWorker['totalIncome'] as num?) ?? 0).toInt();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: const Icon(
              Icons.emoji_events,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Өнөөдрийн шилдэг ажилчин',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: $workerCode',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  workerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text('Угаалт: $washes'),
                Text('Орлого: ${formatMoney(income)}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRecentBookings() {
    if (recentBookings.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text('Сүүлийн захиалга алга'),
      );
    }

    return Column(
      children: recentBookings.map((booking) {
        final String customer = booking['customerName']?.toString() ?? '-';
        final String plate = booking['carPlate']?.toString() ?? '-';
        final String time = booking['bookingTime']?.toString() ?? '-';
        final String worker = booking['workerName']?.toString() ?? '-';
        final String workerCode = booking['workerCode']?.toString() ?? 'N/A';
        final String status = booking['status']?.toString() ?? '-';

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.info.withValues(alpha: 0.12),
                child: const Icon(Icons.event_note, color: AppColors.info),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$customer • $plate',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text('⏰ $time'),
                    Text('👷 ID:$workerCode - $worker'),
                    Text('📌 $status'),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
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
                    buildSummaryCards(),
                    const SizedBox(height: 10),
                    buildSecondaryStats(),
                    const SizedBox(height: 16),
                    buildGrid(),
                    const SizedBox(height: 16),
                    buildTopWorkerCard(),
                    const SizedBox(height: 16),
                    buildRecentBookings(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
      ),
    );
  }
}
