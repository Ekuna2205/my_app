import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/wash_record_model.dart';
import '../services/database_service.dart';
import '../core/constants.dart';

class ManualWashPage extends StatefulWidget {
  @override
  State<ManualWashPage> createState() => _ManualWashPageState();
}

class _ManualWashPageState extends State<ManualWashPage> {
  final carController = TextEditingController();
  String selectedService = AppConstants.manualServices.first;

  int getPrice(String service) {
    switch (service) {
      case "Гадна":
        return 15000;
      case "Дотор":
        return 10000;
      case "Бүтэн":
        return 25000;
      case "Вакум":
        return 8000;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    var db = Provider.of<DatabaseService>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Гар угаалга")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: carController,
              decoration: InputDecoration(labelText: "Машины дугаар"),
            ),
            DropdownButton(
              value: selectedService,
              isExpanded: true,
              items: AppConstants.manualServices
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedService = value.toString();
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                db.addManualWash(
                  WashRecord(
                    carNumber: carController.text,
                    serviceType: selectedService,
                    price: getPrice(selectedService),
                    time: DateTime.now(),
                  ),
                );
                Navigator.pop(context);
              },
              child: Text("Бүртгэх"),
            ),
          ],
        ),
      ),
    );
  }
}
