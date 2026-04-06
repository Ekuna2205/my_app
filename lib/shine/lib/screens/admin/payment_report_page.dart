import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class PaymentReportPage extends StatefulWidget {
  const PaymentReportPage({super.key});

  @override
  State<PaymentReportPage> createState() => _PaymentReportPageState();
}

class _PaymentReportPageState extends State<PaymentReportPage> {
  bool loading = true;
  int paidCount = 0;
  int unpaidCount = 0;
  List<Map<String, dynamic>> records = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final Map<String, int> stats = await DatabaseHelper.instance
        .getPaymentStats();
    final List<Map<String, dynamic>> list = await DatabaseHelper.instance
        .getWashRecords();

    if (!mounted) return;

    setState(() {
      paidCount = stats['paid'] ?? 0;
      unpaidCount = stats['unpaid'] ?? 0;
      records = list;
      loading = false;
    });
  }

  Color statusColor(String status) {
    return status == 'paid' ? Colors.green : Colors.red;
  }

  String statusText(String status) {
    return status == 'paid' ? 'Төлсөн' : 'Төлөөгүй';
  }

  Widget summaryCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 12),
              Text(title),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget recordCard(Map<String, dynamic> item) {
    final String carNumber = item['carNumber']?.toString() ?? '';
    final String workerName = item['workerName']?.toString() ?? '';
    final String washType = item['washType']?.toString() ?? '';
    final int price = ((item['price'] as num?) ?? 0).toInt();
    final String paymentStatus = item['paymentStatus']?.toString() ?? 'unpaid';
    final String date = item['date']?.toString() ?? '';

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor(paymentStatus).withValues(alpha: 0.12),
          child: Icon(
            paymentStatus == 'paid' ? Icons.check : Icons.close,
            color: statusColor(paymentStatus),
          ),
        ),
        title: Text(carNumber),
        subtitle: Text('$workerName\n$washType\n$date'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$price₮',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              statusText(paymentStatus),
              style: TextStyle(
                color: statusColor(paymentStatus),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Төлбөрийн тайлан'), centerTitle: true),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      summaryCard(
                        title: 'Төлсөн',
                        value: '$paidCount',
                        color: Colors.green,
                        icon: Icons.check_circle,
                      ),
                      summaryCard(
                        title: 'Төлөөгүй',
                        value: '$unpaidCount',
                        color: Colors.red,
                        icon: Icons.error,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...records.map(recordCard),
                ],
              ),
            ),
    );
  }
}
