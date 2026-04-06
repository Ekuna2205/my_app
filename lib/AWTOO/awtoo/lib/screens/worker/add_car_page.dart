import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/car.dart';

class AddCarPage extends StatefulWidget {
  final Car? car;

  const AddCarPage({super.key, this.car});

  @override
  State<AddCarPage> createState() => _AddCarPageState();
}

class _AddCarPageState extends State<AddCarPage> {
  final plateController = TextEditingController();
  final modelController = TextEditingController();
  final priceController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.car != null) {
      plateController.text = widget.car!.plateNumber;
      modelController.text = widget.car!.model;
      priceController.text = widget.car!.price.toString();
    }
  }

  Future<void> saveCar() async {
    final plate = plateController.text.trim();
    final model = modelController.text.trim();
    final price = int.tryParse(priceController.text.trim()) ?? 0;

    if (plate.isEmpty || model.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Мэдээллээ бөглөнө үү")));
      return;
    }

    if (widget.car == null) {
      await DatabaseHelper.instance.insertCar(
        Car(plateNumber: plate, model: model, price: price),
      );
    } else {
      await DatabaseHelper.instance.updateCar(
        Car(id: widget.car!.id, plateNumber: plate, model: model, price: price),
      );
    }

    if (!mounted) {
      return;
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Машин нэмэх")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: plateController,
              decoration: const InputDecoration(labelText: "Дугаар"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: modelController,
              decoration: const InputDecoration(labelText: "Модель"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Үнэ"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: saveCar, child: const Text("Хадгалах")),
          ],
        ),
      ),
    );
  }
}
