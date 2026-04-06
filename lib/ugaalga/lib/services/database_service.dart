import 'package:flutter/material.dart';
import '../models/wash_record_model.dart';

class DatabaseService extends ChangeNotifier {
  List<WashRecord> _manualRecords = [];

  List<WashRecord> get manualRecords => _manualRecords;

  void addManualWash(WashRecord record) {
    _manualRecords.add(record);
    notifyListeners();
  }

  int get totalIncome =>
      _manualRecords.fold(0, (sum, item) => sum + item.price);

  int get totalCars => _manualRecords.length;
}
