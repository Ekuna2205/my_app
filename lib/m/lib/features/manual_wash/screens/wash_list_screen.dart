// lib/features/manual_wash/screens/wash_list_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/wash_record.dart';

class WashListScreen extends StatelessWidget {
  const WashListScreen({super.key}); // ← энд const байж болно

  // dummyWashes-г final болгож, const хас (runtime-д зөвшөөрөгдөнө)
  final List<WashRecord> dummyWashes = [
    WashRecord(
      id: '1',
      plateNumber: 'УБА 5678',
      carType: 'жийп',
      washType: 'бүтэн',
      workerId: 'Бат',
      startTime: DateTime(
        2026,
        3,
        5,
        13,
        0,
      ), // ← now() биш статик утга (туршилтад)
      price: 40000,
    ),
    WashRecord(
      id: '2',
      plateNumber: 'НАА 9101',
      carType: 'суудлын',
      washType: 'гадна',
      workerId: 'Сувд',
      startTime: DateTime(2026, 3, 5, 14, 0),
      price: 15000,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final totalIncome = dummyWashes.fold<double>(0, (sum, w) => sum + w.price);
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: Text('Өнөөдрийн угаалга ($today)')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Нийт орлого:', style: TextStyle(fontSize: 18)),
                    Text(
                      NumberFormat.currency(
                        locale: 'mn_MN',
                        symbol: '₮',
                      ).format(totalIncome),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: dummyWashes.length,
              itemBuilder: (context, index) {
                final wash = dummyWashes[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(wash.carType[0].toUpperCase()),
                  ),
                  title: Text(
                    wash.plateNumber,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${wash.washType} • ${wash.workerId}'),
                  trailing: Text(
                    NumberFormat.currency(
                      locale: 'mn_MN',
                      symbol: '₮',
                      decimalDigits: 0,
                    ).format(wash.price),
                    style: const TextStyle(fontSize: 16, color: Colors.green),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const WashFormScreen(),
            ), // ← const хасах эсвэл файл байгаа эсэх шалга
          );
        },
        label: const Text('Шинэ бүртгэл'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
