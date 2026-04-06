import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class AdminIncomeChart extends StatefulWidget {
  const AdminIncomeChart({super.key});

  @override
  State<AdminIncomeChart> createState() => _AdminIncomeChartState();
}

class _AdminIncomeChartState extends State<AdminIncomeChart> {
  List<Map<String, dynamic>> data = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final rows = await DatabaseHelper.instance.getLast7DaysIncome();
    setState(() => data = rows);
  }

  @override
  Widget build(BuildContext context) {
    final maxValue = data.isEmpty
        ? 0
        : data.map((e) => (e['total'] as int)).reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(title: const Text("7 хоногийн орлого")),
      body: data.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      itemCount: data.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final day = data[i]['day'] as String;
                        final total = data[i]['total'] as int;
                        final ratio = maxValue == 0 ? 0.0 : total / maxValue;

                        return Row(
                          children: [
                            SizedBox(width: 90, child: Text(day.substring(5))),
                            Expanded(
                              child: Container(
                                height: 18,
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: ratio.clamp(0.0, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(width: 90, child: Text("$total₮")),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text("※ Энэ бол package хэрэггүй simple chart"),
                ],
              ),
            ),
    );
  }
}
