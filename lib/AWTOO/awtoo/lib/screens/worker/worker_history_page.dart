import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class WorkerHistoryPage extends StatefulWidget {
  final String workerName;

  const WorkerHistoryPage({super.key, required this.workerName});

  @override
  State<WorkerHistoryPage> createState() => _WorkerHistoryPageState();
}

class _WorkerHistoryPageState extends State<WorkerHistoryPage> {
  bool loading = true;
  List<Map<String, dynamic>> records = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final List<Map<String, dynamic>> data = await DatabaseHelper.instance
        .getWorkerWashHistory(widget.workerName);

    if (!mounted) return;

    setState(() {
      records = data;
      loading = false;
    });
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

  String formatDate(String raw) {
    if (raw.isEmpty) return '-';
    if (raw.length >= 16) {
      return raw.substring(0, 16).replaceFirst('T', ' ');
    }
    return raw;
  }

  Color paymentColor(String status) {
    return status == 'paid' ? Colors.green : Colors.red;
  }

  String paymentText(String status) {
    return status == 'paid' ? 'Төлсөн' : 'Төлөөгүй';
  }

  Widget buildSummaryCard() {
    final int totalCount = records.length;

    int totalIncome = 0;
    int paidIncome = 0;
    int unpaidIncome = 0;

    for (final Map<String, dynamic> item in records) {
      final int price = ((item['price'] as num?) ?? 0).toInt();
      final String paymentStatus =
          item['paymentStatus']?.toString() ?? 'unpaid';

      totalIncome += price;

      if (paymentStatus == 'paid') {
        paidIncome += price;
      } else {
        unpaidIncome += price;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Миний угаалтын хураангуй',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: buildMiniInfo(
                  title: 'Нийт',
                  value: '$totalCount',
                  color: Colors.blue,
                  icon: Icons.local_car_wash,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: buildMiniInfo(
                  title: 'Орлого',
                  value: '$totalIncome₮',
                  color: Colors.orange,
                  icon: Icons.payments,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: buildMiniInfo(
                  title: 'Төлсөн',
                  value: '$paidIncome₮',
                  color: Colors.green,
                  icon: Icons.check_circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: buildMiniInfo(
                  title: 'Төлөөгүй',
                  value: '$unpaidIncome₮',
                  color: Colors.red,
                  icon: Icons.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildMiniInfo({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget buildHistoryCard(Map<String, dynamic> item, int index) {
    final String carNumber = item['carNumber']?.toString() ?? '';
    final String rawWashType = item['washType']?.toString() ?? '';
    final int price = ((item['price'] as num?) ?? 0).toInt();
    final String date = item['date']?.toString() ?? '';
    final String paymentStatus = item['paymentStatus']?.toString() ?? 'unpaid';

    final Map<String, String> parsed = splitWashType(rawWashType);
    final String washType = parsed['washType'] ?? '-';
    final String carType = parsed['carType'] ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// top row
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue.withValues(alpha: 0.12),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  carNumber,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: paymentColor(paymentStatus).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  paymentText(paymentStatus),
                  style: TextStyle(
                    color: paymentColor(paymentStatus),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          infoRow(
            icon: Icons.cleaning_services,
            label: 'Угаалгын төрөл',
            value: washType,
          ),
          const SizedBox(height: 8),
          infoRow(
            icon: Icons.directions_car,
            label: 'Машины төрөл',
            value: carType,
          ),
          const SizedBox(height: 8),
          infoRow(
            icon: Icons.payments,
            label: 'Үнэ',
            value: '$price₮',
            valueColor: Colors.orange,
          ),
          const SizedBox(height: 8),
          infoRow(
            icon: Icons.calendar_month,
            label: 'Огноо',
            value: formatDate(date),
          ),
        ],
      ),
    );
  }

  Widget infoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade700),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5B86E5), Color(0xFF36D1DC)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Өмнөх угаалтууд',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Ажилчин: ${widget.workerName}',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Угаалтын түүх'), centerTitle: true),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: loadHistory,
                child: records.isEmpty
                    ? ListView(
                        padding: const EdgeInsets.all(16),
                        children: const [
                          SizedBox(height: 120),
                          Center(
                            child: Text(
                              'Угаалтын түүх алга',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      )
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          buildHeader(),
                          const SizedBox(height: 14),
                          buildSummaryCard(),
                          const SizedBox(height: 14),
                          ...List.generate(
                            records.length,
                            (int index) =>
                                buildHistoryCard(records[index], index),
                          ),
                        ],
                      ),
              ),
      ),
    );
  }
}
