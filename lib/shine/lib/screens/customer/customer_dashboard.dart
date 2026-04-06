import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../services/session_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_background.dart';
import '../../widgets/dashboard_menu_card.dart';
import '../../widgets/stat_card.dart';
import '../login/login_page.dart';
import '../public/booking_calendar_page.dart';
import 'customer_chart_page.dart';
import 'customer_profile_page.dart';
import 'customer_worker_request_page.dart';
import 'self_wash_page.dart';

class CustomerDashboard extends StatefulWidget {
  final String phone;

  const CustomerDashboard({super.key, required this.phone});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  Map<String, dynamic>? customer;
  Map<String, dynamic>? lastWash;

  bool loading = true;

  int totalWash = 0;
  int totalSpent = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final Map<String, dynamic>? customerData = await DatabaseHelper.instance
        .getCustomerByPhone(widget.phone);

    final Map<String, dynamic> stats = await DatabaseHelper.instance
        .getCustomerWashStatsByPhone(widget.phone);

    final Map<String, dynamic>? lastWashData = await DatabaseHelper.instance
        .getLastWashByPhone(widget.phone);

    if (!mounted) return;

    setState(() {
      customer = customerData;
      lastWash = lastWashData;
      totalWash = ((stats['totalWashCount'] as num?) ?? 0).toInt();
      totalSpent = ((stats['totalSpent'] as num?) ?? 0).toInt();
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

  String formatDate(String raw) {
    if (raw.isEmpty) return '-';
    if (raw.length >= 16) {
      return raw.substring(0, 16).replaceFirst('T', ' ');
    }
    return raw;
  }

  Map<String, String> splitWashType(String value) {
    if (value.contains('/')) {
      final List<String> parts = value.split('/');
      final String washType = parts.isNotEmpty ? parts[0].trim() : '';
      final String carType = parts.length > 1 ? parts[1].trim() : '';
      return <String, String>{'washType': washType, 'carType': carType};
    }

    return <String, String>{'washType': value, 'carType': '-'};
  }

  Widget buildHeader() {
    final String name = customer?['fullName']?.toString() ?? 'Хэрэглэгч';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withValues(alpha: 0.16),
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Customer Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Text(name, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildLastWashCard() {
    if (lastWash == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Column(
          children: [
            Icon(Icons.local_car_wash, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'Сүүлийн угаалтын мэдээлэл алга',
              style: TextStyle(
                color: AppColors.textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    final String date = lastWash!['date']?.toString() ?? '-';
    final String worker = lastWash!['workerName']?.toString() ?? '-';
    final String rawWashType = lastWash!['washType']?.toString() ?? '-';
    final int price = ((lastWash!['price'] as num?) ?? 0).toInt();

    final Map<String, String> parsed = splitWashType(rawWashType);
    final String washType = parsed['washType'] ?? '-';
    final String carType = parsed['carType'] ?? '-';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: const Icon(Icons.history, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Сүүлийн угаалт',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  formatDate(date),
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text('👷 $worker', style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 4),
                Text('🧼 $washType', style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 4),
                Text('🚗 $carType', style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
          Text(
            '$price₮',
            style: const TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget quickBookingButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BookingCalendarPage()),
          ).then((_) => loadData());
        },
        icon: const Icon(Icons.flash_on),
        label: const Text('⚡ Шууд цаг захиалах'),
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
          icon: Icons.person_search,
          title: 'Ажилчин дуудах',
          subtitle: 'Шууд хүсэлт',
          color: AppColors.primary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CustomerWorkerRequestPage(phone: widget.phone),
              ),
            ).then((_) => loadData());
          },
        ),
        DashboardMenuCard(
          icon: Icons.event,
          title: 'Цаг захиалах',
          subtitle: 'Booking хийх',
          color: AppColors.success,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BookingCalendarPage()),
            ).then((_) => loadData());
          },
        ),
        DashboardMenuCard(
          icon: Icons.local_car_wash,
          title: 'Өөрөө угаах',
          subtitle: 'Timer ажиллана',
          color: AppColors.secondary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SelfWashPage(customerPhone: widget.phone),
              ),
            ).then((_) => loadData());
          },
        ),
        DashboardMenuCard(
          icon: Icons.bar_chart,
          title: 'Миний график',
          subtitle: '7 хоногийн тайлан',
          color: AppColors.info,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CustomerChartPage(phone: widget.phone),
              ),
            ).then((_) => loadData());
          },
        ),
        DashboardMenuCard(
          icon: Icons.person,
          title: 'Профайл',
          subtitle: 'Мэдээлэл засах',
          color: Colors.purple,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CustomerProfilePage(phone: widget.phone),
              ),
            ).then((_) => loadData());
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadData),
          IconButton(icon: const Icon(Icons.logout), onPressed: logout),
        ],
      ),
      body: AppBackground(
        child: RefreshIndicator(
          onRefresh: loadData,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              buildHeader(),
              const SizedBox(height: 14),
              Row(
                children: [
                  StatCard(
                    icon: Icons.local_car_wash,
                    title: 'Нийт угаалт',
                    value: '$totalWash',
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 10),
                  StatCard(
                    icon: Icons.payments,
                    title: 'Нийт зардал',
                    value: '$totalSpent₮',
                    color: AppColors.success,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              buildLastWashCard(),
              const SizedBox(height: 14),
              quickBookingButton(),
              const SizedBox(height: 14),
              buildGrid(),
            ],
          ),
        ),
      ),
    );
  }
}
