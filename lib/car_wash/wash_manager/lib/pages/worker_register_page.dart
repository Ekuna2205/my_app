import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../database/app_db.dart';
import '../providers/db_providers.dart';

class WorkerRegisterPage extends ConsumerStatefulWidget {
  const WorkerRegisterPage({super.key});

  @override
  ConsumerState<WorkerRegisterPage> createState() => _WorkerRegisterPageState();
}

class _WorkerRegisterPageState extends ConsumerState<WorkerRegisterPage> {
  final _plateController = TextEditingController();
  String? _vehicle;
  int? _serviceId;
  int? _price;

  final vehicles = ['Суудлын', 'Жийп', 'Микро'];

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    final db = ref.read(databaseProvider);
    final count = await db.select(db.serviceTypes).get().then((v) => v.length);
    if (count == 0) {
      await db.batch((batch) {
        batch.insertAll(db.serviceTypes, [
          ServiceTypesCompanion.insert(
              name: 'Гадна угаалга', vehicleType: 'Суудлын', price: 15000),
          ServiceTypesCompanion.insert(
              name: 'Гадна угаалга', vehicleType: 'Жийп', price: 20000),
          ServiceTypesCompanion.insert(
              name: 'Бүтэн угаалга', vehicleType: 'Суудлын', price: 35000),
          ServiceTypesCompanion.insert(
              name: 'Вакум', vehicleType: 'Бүх төрөл', price: 5000),
        ]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(
        databaseProvider.select((db) => db.select(db.serviceTypes).get()));

    return Scaffold(
      appBar: AppBar(title: const Text('Машин бүртгэх')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _plateController,
              decoration: const InputDecoration(
                labelText: 'Машины дугаар (жишээ: 1234 АБ)',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _vehicle,
              decoration: const InputDecoration(labelText: 'Машины төрөл'),
              items: vehicles
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: (v) => setState(() => _vehicle = v),
            ),
            const SizedBox(height: 20),
            servicesAsync.when(
              data: (services) {
                final filtered = services
                    .where((s) =>
                        _vehicle == null ||
                        s.vehicleType == _vehicle ||
                        s.vehicleType == 'Бүх төрөл')
                    .toList();

                return DropdownButtonFormField<int>(
                  value: _serviceId,
                  decoration: const InputDecoration(labelText: 'Үйлчилгээ'),
                  items: filtered
                      .map((s) => DropdownMenuItem(
                            value: s.id,
                            child: Text(
                                '${s.name} — ${NumberFormat("#,###").format(s.price)}₮'),
                          ))
                      .toList(),
                  onChanged: (id) {
                    setState(() {
                      _serviceId = id;
                      _price = services.firstWhere((s) => s.id == id).price;
                    });
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Үйлчилгээ ачаалж чадсангүй'),
            ),
            const SizedBox(height: 30),
            if (_price != null)
              Center(
                child: Text(
                  'Нийт: ${NumberFormat("#,###").format(_price)} ₮',
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
              ),
            const SizedBox(height: 40),
            FilledButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('БҮРТГЭХ', style: TextStyle(fontSize: 20)),
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(60)),
              onPressed: (_serviceId == null ||
                      _plateController.text.trim().isEmpty)
                  ? null
                  : () async {
                      final db = ref.read(databaseProvider);
                      await db.into(db.washRecords).insert(WashRecordsCompanion(
                            plate: Value(_plateController.text.trim()),
                            serviceId: Value(_serviceId!),
                            workerId: const Value(1), // одоохондоо 1 гэж
                            time: Value(DateTime.now()),
                            amount: Value(_price!),
                          ));

                      Fluttertoast.showToast(
                          msg: 'Амжилттай бүртгэлээ!',
                          gravity: ToastGravity.CENTER);
                      _plateController.clear();
                      setState(() {
                        _vehicle = null;
                        _serviceId = null;
                        _price = null;
                      });
                    },
            ),
          ],
        ),
      ),
    );
  }
}
