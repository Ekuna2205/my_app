import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class CustomerPriceQrPage extends StatefulWidget {
  const CustomerPriceQrPage({super.key});

  @override
  State<CustomerPriceQrPage> createState() => _CustomerPriceQrPageState();
}

class _CustomerPriceQrPageState extends State<CustomerPriceQrPage> {
  List<Map<String, dynamic>> prices = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await DatabaseHelper.instance.seedPricesIfEmpty();
    final data = await DatabaseHelper.instance.getPrices();
    if (!mounted) return;
    setState(() {
      prices = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Үнэ харах (Customer)")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: prices.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final p = prices[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.local_car_wash),
                    title: Text("${p['washType']}"),
                    trailing: Text(
                      "${p['price']}₮",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
