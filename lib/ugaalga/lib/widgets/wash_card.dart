import 'package:flutter/material.dart';
import '../models/wash_record_model.dart';

class WashCard extends StatelessWidget {
  final WashRecord record;

  const WashCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(record.carNumber),
        subtitle: Text(record.serviceType),
        trailing: Text("${record.price} ₮"),
      ),
    );
  }
}
