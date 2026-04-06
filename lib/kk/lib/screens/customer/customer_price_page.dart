import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class CustomerPricePage extends StatefulWidget {
  const CustomerPricePage({super.key});

  @override
  State<CustomerPricePage> createState() => _CustomerPricePageState();
}

class _CustomerPricePageState extends State<CustomerPricePage> {
  bool loading = true;
  List<Map<String, dynamic>> prices = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);

    // Seed байхгүй бол default үнэ оруулна (аюулгүй)
    await DatabaseHelper.instance.seedPricesIfEmpty();

    final data = await DatabaseHelper.instance.getPrices();
    setState(() {
      prices = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // service-ээр бүлэглэх
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final p in prices) {
      final service = (p['service'] ?? '') as String;
      grouped.putIfAbsent(service, () => []);
      grouped[service]!.add(p);
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Үнэ тариф")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  for (final entry in grouped.entries) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 14, 8, 8),
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    ...entry.value.map((p) {
                      final type = (p['type'] ?? '') as String;
                      final price = (p['price'] ?? 0) as int;

                      final isMinute = type == 'Минут';

                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Icon(
                              isMinute ? Icons.timer : Icons.local_car_wash,
                            ),
                          ),
                          title: Text(
                            type,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            isMinute
                                ? "Минутын тариф"
                                : "Нэг удаагийн үйлчилгээ",
                          ),
                          trailing: Text(
                            isMinute ? "$price₮/мин" : "$price₮",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 6),
                  ],
                  const SizedBox(height: 18),
                  Text(
                    "ℹ️ Үнийн мэдээлэл өөрчлөгдөж болно. Дэлгэрэнгүйг ажилтнаас асууна уу.",
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}
