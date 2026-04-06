import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/car.dart';
import '../worker/add_car_page.dart';

class AdminCarList extends StatefulWidget {
  const AdminCarList({super.key});

  @override
  State<AdminCarList> createState() => _AdminCarListState();
}

class _AdminCarListState extends State<AdminCarList> {
  List<Car> cars = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  Future<void> _loadCars() async {
    setState(() => loading = true);
    final data = await DatabaseHelper.instance.getCars();
    setState(() {
      cars = data;
      loading = false;
    });
  }

  Future<void> _deleteCar(int id) async {
    await DatabaseHelper.instance.deleteCar(id);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Устгалаа ✅")));
    _loadCars();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Машины жагсаалт (Admin)")),
      body: RefreshIndicator(
        onRefresh: _loadCars,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : cars.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text("Одоогоор машин алга")),
                ],
              )
            : ListView.builder(
                itemCount: cars.length,
                itemBuilder: (context, index) {
                  final car = cars[index];
                  return Card(
                    child: ListTile(
                      title: Text(
                        car.plateNumber,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("${car.model} | ${car.price}₮"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddCarPage(car: car),
                                ),
                              );
                              if (result == true) _loadCars();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteCar(car.id!),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCarPage()),
          );
          if (result == true) _loadCars();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
