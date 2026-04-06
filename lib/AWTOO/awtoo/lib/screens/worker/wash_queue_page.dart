import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class WashQueuePage extends StatefulWidget {
  const WashQueuePage({super.key});

  @override
  State<WashQueuePage> createState() => _WashQueuePageState();
}

class _WashQueuePageState extends State<WashQueuePage> {
  final TextEditingController plateController = TextEditingController();

  List<Map<String, dynamic>> queue = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadQueue();
  }

  Future<void> loadQueue() async {
    final data = await DatabaseHelper.instance.getWashRecords();

    setState(() {
      queue = data;
      loading = false;
    });
  }

  Future<void> addToQueue() async {
    final plate = plateController.text.trim();

    if (plate.isEmpty) return;

    await DatabaseHelper.instance.insertWashRecord({
      "carNumber": plate,
      "workerName": "Queue",
      "washType": "Хүлээгдэж байна",
      "price": 0,
      "date": DateTime.now().toString(),
    });

    plateController.clear();
    loadQueue();
  }

  Future<void> deleteItem(int id) async {
    final db = await DatabaseHelper.instance.database;

    await db.delete("wash_records", where: "id = ?", whereArgs: [id]);

    loadQueue();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Wash Queue")),

      body: Column(
        children: [
          /// Add queue
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: plateController,
                    decoration: const InputDecoration(
                      labelText: "Машины дугаар",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: addToQueue,
                  child: const Text("Нэмэх"),
                ),
              ],
            ),
          ),

          const Divider(),

          /// Queue list
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : queue.isEmpty
                ? const Center(child: Text("Queue хоосон"))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: queue.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),

                    itemBuilder: (context, i) {
                      final item = queue[i];

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(child: Text("${i + 1}")),

                          title: Text(
                            item["carNumber"] ?? "",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),

                          subtitle: Text(item["washType"] ?? ""),

                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              deleteItem(item["id"]);
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
