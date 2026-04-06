import 'package:flutter/material.dart';

class CustomerPricePage extends StatelessWidget {
  const CustomerPricePage({super.key});

  static const List<String> washTypes = <String>[
    'Бүтэн',
    'Гадар',
    'Дотор',
    'Чэнж',
    'Тааз',
    'Шал',
  ];

  static const List<String> vehicleTypes = <String>[
    'Жижиг',
    'Дунд',
    'Том',
    'Гэр бүлийн',
    'Ачааны',
  ];

  static const Map<String, Map<String, int>> workerPriceTable =
      <String, Map<String, int>>{
        'Бүтэн': <String, int>{
          'Жижиг': 40000,
          'Дунд': 50000,
          'Том': 60000,
          'Гэр бүлийн': 70000,
          'Ачааны': 60000,
        },
        'Гадар': <String, int>{
          'Жижиг': 30000,
          'Дунд': 37000,
          'Том': 45000,
          'Гэр бүлийн': 50000,
          'Ачааны': 25000,
        },
        'Дотор': <String, int>{
          'Жижиг': 30000,
          'Дунд': 37000,
          'Том': 45000,
          'Гэр бүлийн': 50000,
          'Ачааны': 25000,
        },
        'Чэнж': <String, int>{
          'Жижиг': 250000,
          'Дунд': 300000,
          'Том': 500000,
          'Гэр бүлийн': 550000,
          'Ачааны': 230000,
        },
        'Тааз': <String, int>{
          'Жижиг': 30000,
          'Дунд': 35000,
          'Том': 40000,
          'Гэр бүлийн': 45000,
          'Ачааны': 25000,
        },
        'Шал': <String, int>{
          'Жижиг': 30000,
          'Дунд': 35000,
          'Том': 40000,
          'Гэр бүлийн': 45000,
          'Ачааны': 25000,
        },
      };

  static const Map<String, int> selfWashPrices = <String, int>{
    'Жижиг': 35000,
    'Дунд': 45000,
    'Том': 55000,
    'Гэр бүлийн': 65000,
    'Ачааны': 55000,
  };

  Widget buildWorkerPriceTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 18,
        columns: const <DataColumn>[
          DataColumn(label: Text('Төрөл')),
          DataColumn(label: Text('Жижиг')),
          DataColumn(label: Text('Дунд')),
          DataColumn(label: Text('Том')),
          DataColumn(label: Text('Гэр бүлийн')),
          DataColumn(label: Text('Ачааны')),
        ],
        rows: washTypes.map((String washType) {
          final Map<String, int> row = workerPriceTable[washType]!;
          return DataRow(
            cells: <DataCell>[
              DataCell(Text(washType)),
              DataCell(Text('${row['Жижиг']}₮')),
              DataCell(Text('${row['Дунд']}₮')),
              DataCell(Text('${row['Том']}₮')),
              DataCell(Text('${row['Гэр бүлийн']}₮')),
              DataCell(Text('${row['Ачааны']}₮')),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget buildSelfWashPriceTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 18,
        columns: const <DataColumn>[
          DataColumn(label: Text('Машины төрөл')),
          DataColumn(label: Text('Үнэ')),
        ],
        rows: vehicleTypes.map((String type) {
          return DataRow(
            cells: <DataCell>[
              DataCell(Text(type)),
              DataCell(Text('${selfWashPrices[type]}₮')),
            ],
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Үнэ харах"), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Үнийн мэдээлэл",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Ажилтнаар угаалгах болон өөрөө угаах үнэ",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              "Өөрөө угаах үнийн хүснэгт",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          buildSelfWashPriceTable(),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              "Ажилтны угаалгын үнийн хүснэгт",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          buildWorkerPriceTable(),
        ],
      ),
    );
  }
}
