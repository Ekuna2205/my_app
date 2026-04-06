import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/db_providers.dart';

class AdminReportPage extends ConsumerWidget {
  const AdminReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomeAsync = ref.watch(todayIncomeProvider);
    final recordsAsync = ref.watch(todayRecordsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Өнөөдрийн тайлан')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: incomeAsync.when(
                  data: (income) => Text(
                    'Нийт орлого: ${NumberFormat("#,###").format(income)} ₮',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.green[800],
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const Text('Алдаа гарлаа'),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: recordsAsync.when(
                data: (records) => records.isEmpty
                    ? const Center(child: Text('Өнөөдөр бүртгэл байхгүй байна'))
                    : ListView.builder(
                        itemCount: records.length,
                        itemBuilder: (context, index) {
                          final r = records[index];
                          return ListTile(
                            leading: const Icon(Icons.car_repair),
                            title: Text(r.plate),
                            subtitle: Text(
                                '${r.time.hour}:${r.time.minute.toString().padLeft(2, '0')}'),
                            trailing: Text(
                              '${NumberFormat("#,###").format(r.amount)}₮',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          );
                        },
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) =>
                    const Center(child: Text('Тайлан ачаалж чадсангүй')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
