import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:qr_flutter/qr_flutter.dart';

// ────────────────────────────────────────────────
// 1. Drift Database (minimal - зөвхөн гар угаалгын бүртгэл)
// ────────────────────────────────────────────────
part 'main.g.dart'; // build_runner-ээр generate хийгдэнэ

class WashRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get carNumber => text()();
  TextColumn get carType => text()(); // 'Суудлын', 'Жийп', 'Микро'
  TextColumn get serviceType => text()(); // 'Гадна', 'Дотор', 'Бүтэн', 'Вакум'
  IntColumn get workerId => integer()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  IntColumn get amount => integer()(); // төгрөг
}

@DriftDatabase(tables: [WashRecords])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Жишээ query: өнөөдрийн бүртгэлүүд
  Future<List<WashRecord>> getTodayRecords() {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final end = start.add(const Duration(days: 1));
    return (select(
      washRecords,
    )..where((r) => r.startTime.isBetweenValues(start, end))).get();
  }

  Future<int> addWashRecord({
    required String carNumber,
    required String carType,
    required String serviceType,
    required int workerId,
    required int amount,
  }) {
    return into(washRecords).insert(
      WashRecordsCompanion.insert(
        carNumber: carNumber,
        carType: carType,
        serviceType: serviceType,
        workerId: workerId,
        startTime: DateTime.now(),
        amount: amount,
      ),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'auto_wash.db'));
    return NativeDatabase.createInBackground(file);
  });
}

// ────────────────────────────────────────────────
// 2. Riverpod Providers
// ────────────────────────────────────────────────
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final todayRecordsProvider = FutureProvider<List<WashRecord>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getTodayRecords();
});

// ────────────────────────────────────────────────
// 3. Main App
// ────────────────────────────────────────────────
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auto Wash Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
        fontFamily: 'Roboto', // Монгол текстэд тохиромжтой
      ),
      home: const HomeScreen(),
    );
  }
}

// ────────────────────────────────────────────────
// 4. Home Screen (Worker-ийн гол дэлгэц)
// ────────────────────────────────────────────────
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(todayRecordsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Өнөөдрийн угаалга'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SelfServiceScreen()),
              );
            },
          ),
        ],
      ),
      body: recordsAsync.when(
        data: (records) => records.isEmpty
            ? const Center(child: Text('Өнөөдөр бүртгэл байхгүй'))
            : ListView.builder(
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final r = records[index];
                  return ListTile(
                    leading: const Icon(Icons.car_repair),
                    title: Text(r.carNumber),
                    subtitle: Text('${r.carType} • ${r.serviceType}'),
                    trailing: Text('${r.amount}₮'),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Алдаа: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    String carNumber = '';
    String carType = 'Суудлын';
    String service = 'Гадна';
    int amount = 15000;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Шинэ угаалга бүртгэх'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Машины дугаар'),
              onChanged: (v) => carNumber = v,
            ),
            DropdownButtonFormField<String>(
              value: carType,
              items: [
                'Суудлын',
                'Жийп',
                'Микро',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => carType = v ?? carType,
            ),
            DropdownButtonFormField<String>(
              value: service,
              items: [
                'Гадна',
                'Дотор',
                'Бүтэн',
                'Вакум',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) {
                service = v ?? service;
                amount = service == 'Гадна' ? 15000 : 25000; // жишээ үнэ
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Болих'),
          ),
          TextButton(
            onPressed: () async {
              if (carNumber.isNotEmpty) {
                await ref
                    .read(databaseProvider)
                    .addWashRecord(
                      carNumber: carNumber,
                      carType: carType,
                      serviceType: service,
                      workerId: 1, // одоогоор hardcode (дараа auth нэмнэ)
                      amount: amount,
                    );
                ref.invalidate(todayRecordsProvider);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Хадгалах'),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────
// 5. Self-service QR дэлгэц (жишээ)
// ────────────────────────────────────────────────
class SelfServiceScreen extends StatelessWidget {
  const SelfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const stationId = "ULAANBAATAR-001"; // station тус бүрт өөр QR

    return Scaffold(
      appBar: AppBar(title: const Text('Өөрөө угаах')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'QR кодыг уншуулж төлнө үү',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 30),
            QrImageView(
              data:
                  'selfwash:$stationId:${DateTime.now().millisecondsSinceEpoch}',
              version: QrVersions.auto,
              size: 280.0,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 20),
            const Text('10 мин = 2000₮', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
