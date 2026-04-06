import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/car.dart';
import 'add_car_page.dart';

class CarListPage extends StatefulWidget {
  const CarListPage({super.key});

  @override
  State<CarListPage> createState() => _CarListPageState();
}

class _CarListPageState extends State<CarListPage> {
  List<Car> cars = [];
  List<Car> filteredCars = [];

  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadCars();

    searchController.addListener(() {
      filterCars();
    });
  }

  Future<void> loadCars() async {
    final data = await DatabaseHelper.instance.getCars();

    setState(() {
      cars = data;
      filteredCars = data;
    });
  }

  void filterCars() {
    final query = searchController.text.toLowerCase();

    setState(() {
      filteredCars = cars.where((car) {
        return car.plateNumber.toLowerCase().contains(query) ||
            car.model.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> deleteCar(int id) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Устгах уу?"),
          content: const Text("Энэ машиныг устгахдаа итгэлтэй байна уу?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Үгүй"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Тийм"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteCar(id);
      loadCars();
    }
  }

  Future<void> openAddPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddCarPage()),
    );

    if (result == true) {
      loadCars();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Машины жагсаалт")),

      floatingActionButton: FloatingActionButton(
        onPressed: openAddPage,
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          /// 🔍 SEARCH
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Машин хайх...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          /// 🚗 LIST
          Expanded(
            child: filteredCars.isEmpty
                ? const Center(
                    child: Text(
                      "Машин олдсонгүй",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.separated(
                    itemCount: filteredCars.length,
                    separatorBuilder: (_, _) => const Divider(),

                    itemBuilder: (context, index) {
                      final car = filteredCars[index];

                      return ListTile(
                        leading: const Icon(Icons.directions_car, size: 30),

                        title: Text(
                          car.plateNumber,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        subtitle: Text("${car.model} | ${car.price}₮"),

                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            deleteCar(car.id!);
                          },
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
