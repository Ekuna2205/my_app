import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class AdminPricePage extends StatefulWidget {
  const AdminPricePage({super.key});

  @override
  State<AdminPricePage> createState() => _AdminPricePageState();
}

class _AdminPricePageState extends State<AdminPricePage> {
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

    setState(() {
      prices = data;
      loading = false;
    });
  }

  Future<void> editPrice(Map<String, dynamic> item) async {
    final controller = TextEditingController(text: item["price"].toString());

    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("${item["washType"]} үнийг засах"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Шинэ үнэ",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Болих"),
            ),
            ElevatedButton(
              onPressed: () {
                final value = int.tryParse(controller.text.trim());
                if (value == null) return;
                Navigator.pop(context, value);
              },
              child: const Text("Хадгалах"),
            ),
          ],
        );
      },
    );

    if (result != null) {
      await DatabaseHelper.instance.setPrice(
        item["washType"] as String,
        result,
      );
      loadPrices();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Үнэ тохируулах"), centerTitle: true),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: prices.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = prices[index];

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.local_car_wash,
                      color: Colors.blue,
                    ),
                    title: Text(
                      item["washType"] ?? "",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      "${item["price"]}₮",
                      style: const TextStyle(fontSize: 15),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        editPrice(item);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
