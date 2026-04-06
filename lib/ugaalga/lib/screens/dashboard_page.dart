import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import 'manual_wash_page.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var db = Provider.of<DatabaseService>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ManualWashPage()),
          );
        },
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: Text("Нийт машин"),
                trailing: Text("${db.totalCars}"),
              ),
            ),
            Card(
              child: ListTile(
                title: Text("Нийт орлого"),
                trailing: Text("${db.totalIncome} ₮"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
