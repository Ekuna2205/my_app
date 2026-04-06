import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';

class CustomerChartPage extends StatefulWidget {
  final String phone;

  const CustomerChartPage({super.key, required this.phone});

  @override
  State<CustomerChartPage> createState() => _CustomerChartPageState();
}

class _CustomerChartPageState extends State<CustomerChartPage> {
  bool loading = true;
  List<Map<String, dynamic>> stats = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> chartData = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    final List<Map<String, dynamic>> data = await DatabaseHelper.instance
        .getCustomerLast7DaysStatsByPhone(widget.phone);

    final List<Map<String, dynamic>> filled = build7DaysData(data);

    if (!mounted) return;

    setState(() {
      stats = data;
      chartData = filled;
      loading = false;
    });
  }

  List<Map<String, dynamic>> build7DaysData(List<Map<String, dynamic>> source) {
    final Map<String, Map<String, dynamic>> sourceMap =
        <String, Map<String, dynamic>>{};

    for (final Map<String, dynamic> item in source) {
      final String day = item['day']?.toString() ?? '';
      if (day.isNotEmpty) {
        sourceMap[day] = item;
      }
    }

    final DateTime now = DateTime.now();
    final List<Map<String, dynamic>> result = <Map<String, dynamic>>[];

    for (int i = 6; i >= 0; i--) {
      final DateTime d = now.subtract(Duration(days: i));
      final String day =
          '${d.year.toString().padLeft(4, '0')}-'
          '${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')}';

      if (sourceMap.containsKey(day)) {
        result.add(<String, dynamic>{
          'day': day,
          'totalWash': ((sourceMap[day]!['totalWash'] as num?) ?? 0).toInt(),
          'totalSpent': ((sourceMap[day]!['totalSpent'] as num?) ?? 0).toInt(),
        });
      } else {
        result.add(<String, dynamic>{
          'day': day,
          'totalWash': 0,
          'totalSpent': 0,
        });
      }
    }

    return result;
  }

  double getMaxSpent() {
    if (chartData.isEmpty) return 1;

    double maxVal = 0;
    for (final Map<String, dynamic> item in chartData) {
      final double value = ((item['totalSpent'] as num?) ?? 0).toDouble();
      if (value > maxVal) {
        maxVal = value;
      }
    }

    return maxVal == 0 ? 1 : maxVal;
  }

  String shortDay(String raw) {
    if (raw.length >= 10) {
      return raw.substring(5, 10);
    }
    return raw;
  }

  Widget buildPageBackground({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF4338CA)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(child: child),
    );
  }

  Widget buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF6366F1), Color(0xFF818CF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha: 0.24),
            blurRadius: 18,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Миний график',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Сүүлийн 7 хоногийн угаалт ба зардал',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget buildSpentChart() {
    final double maxSpent = getMaxSpent();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '7 хоногийн зардал',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 240,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: chartData.map((Map<String, dynamic> item) {
                final double spent = ((item['totalSpent'] as num?) ?? 0)
                    .toDouble();
                final double ratio = spent / maxSpent;
                final String day = shortDay(item['day']?.toString() ?? '');

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${spent.toInt()}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 24,
                        height: spent == 0 ? 8 : (140 * ratio + 8),
                        decoration: BoxDecoration(
                          color: spent == 0
                              ? Colors.grey.shade300
                              : AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(day, style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildWashList() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '7 хоногийн дэлгэрэнгүй',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          const SizedBox(height: 12),
          ...chartData.map((Map<String, dynamic> item) {
            final String day = item['day']?.toString() ?? '-';
            final int totalWash = ((item['totalWash'] as num?) ?? 0).toInt();
            final int totalSpent = ((item['totalSpent'] as num?) ?? 0).toInt();

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: totalWash == 0
                    ? Colors.grey.shade100
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: totalWash == 0
                        ? Colors.grey.withValues(alpha: 0.15)
                        : AppColors.primary.withValues(alpha: 0.12),
                    child: Icon(
                      Icons.calendar_month,
                      color: totalWash == 0 ? Colors.grey : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      day,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Угаалт: $totalWash'),
                      Text(
                        '$totalSpent₮',
                        style: TextStyle(
                          color: totalSpent == 0
                              ? Colors.grey
                              : AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget buildSummaryCard() {
    int totalWash = 0;
    int totalSpent = 0;

    for (final Map<String, dynamic> item in chartData) {
      totalWash += ((item['totalWash'] as num?) ?? 0).toInt();
      totalSpent += ((item['totalSpent'] as num?) ?? 0).toInt();
    }

    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const Icon(Icons.local_car_wash, color: AppColors.secondary),
                const SizedBox(height: 6),
                const Text('7 хоногийн угаалт'),
                const SizedBox(height: 4),
                Text(
                  '$totalWash',
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 60, color: Colors.grey.shade300),
          Expanded(
            child: Column(
              children: [
                const Icon(Icons.payments, color: AppColors.success),
                const SizedBox(height: 6),
                const Text('7 хоногийн зардал'),
                const SizedBox(height: 4),
                Text(
                  '$totalSpent₮',
                  style: const TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Миний график'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: loadStats, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: buildPageBackground(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: loadStats,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    buildHeader(),
                    const SizedBox(height: 14),
                    buildSummaryCard(),
                    const SizedBox(height: 14),
                    buildSpentChart(),
                    const SizedBox(height: 14),
                    buildWashList(),
                  ],
                ),
              ),
      ),
    );
  }
}
