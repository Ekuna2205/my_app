import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class AdminChartPage extends StatefulWidget {
  const AdminChartPage({super.key});

  @override
  State<AdminChartPage> createState() => _AdminChartPageState();
}

class _AdminChartPageState extends State<AdminChartPage> {
  bool loading = true;

  int todayIncome = 0;
  int todayCars = 0;
  int onlineWorkers = 0;
  int pendingRequests = 0;

  Map<String, dynamic> topWorker = <String, dynamic>{};
  Map<String, dynamic> incomeSummary = <String, dynamic>{};

  List<Map<String, dynamic>> dailyIncome = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    loadAll();
  }

  Future<void> loadAll() async {
    final Map<String, int> todaySummary = await DatabaseHelper.instance
        .getTodaySummary();
    final List<Map<String, dynamic>> online = await DatabaseHelper.instance
        .getActiveWorkers();
    final int pending = await DatabaseHelper.instance.getPendingRequestCount();
    final Map<String, dynamic> top = await DatabaseHelper.instance
        .getTopWorkerToday();
    final Map<String, dynamic> summary = await DatabaseHelper.instance
        .getSelfVsWorkerIncomeSummary();
    final List<Map<String, dynamic>> income = await DatabaseHelper.instance
        .getDailyIncomeForChart();

    if (!mounted) return;

    setState(() {
      todayIncome = todaySummary['totalIncome'] ?? 0;
      todayCars = todaySummary['totalCars'] ?? 0;
      onlineWorkers = online.length;
      pendingRequests = pending;
      topWorker = top;
      incomeSummary = summary;
      dailyIncome = income;
      loading = false;
    });
  }

  double getMaxIncome() {
    if (dailyIncome.isEmpty) return 1;

    double maxValue = 0;
    for (final Map<String, dynamic> item in dailyIncome) {
      final double value = ((item['total'] as num?) ?? 0).toDouble();
      if (value > maxValue) {
        maxValue = value;
      }
    }
    return maxValue == 0 ? 1 : maxValue;
  }

  String shortDay(String raw) {
    if (raw.length >= 10) {
      return raw.substring(5, 10);
    }
    return raw;
  }

  Widget topHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PRO ANALYTICS',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Орлого, ажилтан, request, графикийн нэгдсэн самбар',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget metricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget summaryGrid() {
    return Column(
      children: [
        Row(
          children: [
            metricCard(
              title: 'Өнөөдрийн орлого',
              value: '$todayIncome₮',
              icon: Icons.payments,
              color: Colors.green,
            ),
            const SizedBox(width: 10),
            metricCard(
              title: 'Өнөөдрийн угаалт',
              value: '$todayCars',
              icon: Icons.local_car_wash,
              color: Colors.blue,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            metricCard(
              title: 'Online worker',
              value: '$onlineWorkers',
              icon: Icons.circle,
              color: Colors.orange,
            ),
            const SizedBox(width: 10),
            metricCard(
              title: 'Pending request',
              value: '$pendingRequests',
              icon: Icons.notifications_active,
              color: Colors.red,
            ),
          ],
        ),
      ],
    );
  }

  Widget chartCard() {
    final double maxIncome = getMaxIncome();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '7 хоногийн орлого',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          const SizedBox(height: 16),
          if (dailyIncome.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Орлогын мэдээлэл алга'),
              ),
            )
          else
            SizedBox(
              height: 230,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: dailyIncome.map((Map<String, dynamic> item) {
                  final double income = ((item['total'] as num?) ?? 0)
                      .toDouble();
                  final double ratio = income / maxIncome;
                  final String day = shortDay(item['day']?.toString() ?? '');

                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${income.toInt()}',
                          style: const TextStyle(fontSize: 11),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 26,
                          height: 150 * ratio + 8,
                          decoration: BoxDecoration(
                            color: Colors.blue,
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

  Widget topWorkerCard() {
    final String name = topWorker['workerName']?.toString() ?? '-';
    final int washes = ((topWorker['totalWashes'] as num?) ?? 0).toInt();
    final int income = ((topWorker['totalIncome'] as num?) ?? 0).toInt();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.orange.withValues(alpha: 0.14),
            child: const Icon(Icons.emoji_events, color: Colors.orange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Өнөөдрийн TOP ажилтан',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Угаалт: $washes | Орлого: $income₮'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget percentBar({
    required String label,
    required double percent,
    required int income,
    required Color color,
  }) {
    final double safe = percent.clamp(0, 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label - $income₮',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: safe / 100,
            minHeight: 14,
            backgroundColor: Colors.grey.shade300,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        Text('${safe.toStringAsFixed(1)}%'),
      ],
    );
  }

  Widget incomeBreakdownCard() {
    final int selfIncome = ((incomeSummary['selfIncome'] as num?) ?? 0).toInt();
    final int workerIncome = ((incomeSummary['workerIncome'] as num?) ?? 0)
        .toInt();
    final double selfPercent = ((incomeSummary['selfPercent'] as num?) ?? 0)
        .toDouble();
    final double workerPercent = ((incomeSummary['workerPercent'] as num?) ?? 0)
        .toDouble();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Орлогын бүтэц',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          const SizedBox(height: 14),
          percentBar(
            label: 'Өөрөө угаах',
            percent: selfPercent,
            income: selfIncome,
            color: Colors.orange,
          ),
          const SizedBox(height: 14),
          percentBar(
            label: 'Ажилчин угаах',
            percent: workerPercent,
            income: workerIncome,
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Graph Dashboard PRO'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: loadAll, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadAll,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  topHeader(),
                  const SizedBox(height: 14),
                  summaryGrid(),
                  const SizedBox(height: 14),
                  chartCard(),
                  const SizedBox(height: 14),
                  topWorkerCard(),
                  const SizedBox(height: 14),
                  incomeBreakdownCard(),
                ],
              ),
            ),
    );
  }
}
