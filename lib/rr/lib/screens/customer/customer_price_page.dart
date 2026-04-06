import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../widgets/app_background.dart';

class CustomerPricePage extends StatefulWidget {
  const CustomerPricePage({super.key});

  @override
  State<CustomerPricePage> createState() => _CustomerPricePageState();
}

class _CustomerPricePageState extends State<CustomerPricePage> {
  List<Map<String, dynamic>> prices = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadPrices();
  }

  Future<void> loadPrices() async {
    await DatabaseHelper.instance.seedPricesIfEmpty();
    final data = await DatabaseHelper.instance.getPrices();

    if (!mounted) {
      return;
    }

    setState(() {
      prices = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Авто угаалгын үнэ"), centerTitle: true),
      body: AppBackground(
        title: "Үнэ тариф",
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: prices.length,
                itemBuilder: (context, index) {
                  final item = prices[index];

                  return Card(
                    elevation: 6,
                    color: Colors.white.withValues(alpha: 0.92),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const Icon(
                        Icons.local_car_wash,
                        color: Colors.blue,
                      ),
                      title: Text(
                        item["washType"] ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      trailing: Text(
                        "${item["price"]}₮",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
