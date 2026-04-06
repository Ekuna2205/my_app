import 'dart:async';
import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../services/session_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_background.dart';
import '../../widgets/dashboard_menu_card.dart';
import '../../widgets/stat_card.dart';
import '../login/login_page.dart';
import 'worker_history_page.dart';
import 'worker_request_list_page.dart';
import 'worker_wash_page.dart';

class WorkerDashboard extends StatefulWidget {
  final String workerName;
  final String workerUsername;

  const WorkerDashboard({
    super.key,
    required this.workerName,
    required this.workerUsername,
  });

  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard> {
  int todayCount = 0;
  int todayIncome = 0;
  bool summaryLoading = true;

  List<Map<String, dynamic>> pendingRequests = <Map<String, dynamic>>[];
  Timer? requestTimer;
  int lastRequestCount = 0;
  bool popupOpen = false;

  @override
  void initState() {
    super.initState();
    setOnline();
    loadSummary();
    loadPendingRequests(firstLoad: true);

    requestTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await loadPendingRequests();
    });
  }

  Future<void> setOnline() async {
    await DatabaseHelper.instance.setWorkerActiveByUsername(
      username: widget.workerUsername,
      isActive: true,
    );
  }

  Future<void> setOffline() async {
    await DatabaseHelper.instance.setWorkerActiveByUsername(
      username: widget.workerUsername,
      isActive: false,
    );
  }

  Future<void> loadSummary() async {
    final int count = await DatabaseHelper.instance.getWorkerTodayWashCount(
      widget.workerName,
    );
    final int income = await DatabaseHelper.instance.getWorkerTodayIncome(
      widget.workerName,
    );

    if (!mounted) return;

    setState(() {
      todayCount = count;
      todayIncome = income;
      summaryLoading = false;
    });
  }

  Future<void> loadPendingRequests({bool firstLoad = false}) async {
    final List<Map<String, dynamic>> data = await DatabaseHelper.instance
        .getPendingWashRequests();

    if (!mounted) return;

    final int newCount = data.length;

    setState(() {
      pendingRequests = data;
    });

    if (!firstLoad && newCount > lastRequestCount && newCount > 0) {
      showNewRequestPopup(data.first);
    }

    lastRequestCount = newCount;
  }

  void showNewRequestPopup(Map<String, dynamic> item) {
    if (!mounted || popupOpen) return;

    popupOpen = true;

    final String carPlate = item['carPlate']?.toString() ?? '';
    final String vehicleType = item['vehicleType']?.toString() ?? '';
    final String note = item['note']?.toString() ?? '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Шинэ хүсэлт ирлээ'),
        content: Text(
          'Машины дугаар: $carPlate\n'
          'Машины төрөл: $vehicleType\n'
          'Тайлбар: ${note.isEmpty ? 'Байхгүй' : note}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              popupOpen = false;
            },
            child: const Text('Хаах'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              popupOpen = false;

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      WorkerRequestListPage(workerName: widget.workerName),
                ),
              );

              await loadPendingRequests(firstLoad: true);
              await loadSummary();
            },
            child: const Text('Нээх'),
          ),
        ],
      ),
    );
  }

  Future<void> logout() async {
    await setOffline();
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
          colors: [AppColors.primary, Color(0xFF42A5F5)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withValues(alpha: 0.16),
            child: const Icon(Icons.engineering, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ажилчин',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.workerName,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  'Шинэ хүсэлт: ${pendingRequests.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
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
          icon: Icons.local_car_wash,
          title: 'Угаалт бүртгэх',
          subtitle: 'Ажилчин',
          color: AppColors.primary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WorkerWashPage(workerName: widget.workerName),
              ),
            ).then((_) async {
              await loadSummary();
              await loadPendingRequests(firstLoad: true);
            });
          },
        ),
        DashboardMenuCard(
          icon: Icons.notifications_active,
          title: 'Ирсэн хүсэлтүүд',
          subtitle: 'Pending: ${pendingRequests.length}',
          color: AppColors.warning,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    WorkerRequestListPage(workerName: widget.workerName),
              ),
            ).then((_) async {
              await loadSummary();
              await loadPendingRequests(firstLoad: true);
            });
          },
        ),
        DashboardMenuCard(
          icon: Icons.history,
          title: 'Өмнөх угаалт',
          subtitle: 'History list',
          color: AppColors.success,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    WorkerHistoryPage(workerName: widget.workerName),
              ),
            ).then((_) async {
              await loadSummary();
              await loadPendingRequests(firstLoad: true);
            });
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    requestTimer?.cancel();
    setOffline();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Worker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await loadSummary();
              await loadPendingRequests(firstLoad: true);
            },
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: logout),
        ],
      ),
      body: AppBackground(
        child: RefreshIndicator(
          onRefresh: () async {
            await loadSummary();
            await loadPendingRequests(firstLoad: true);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              buildHeader(),
              const SizedBox(height: 14),
              if (summaryLoading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                Row(
                  children: [
                    StatCard(
                      icon: Icons.local_car_wash,
                      title: 'Өнөөдрийн ажил',
                      value: '$todayCount',
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    StatCard(
                      icon: Icons.payments,
                      title: 'Өдрийн орлого',
                      value: '$todayIncome₮',
                      color: AppColors.success,
                    ),
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
