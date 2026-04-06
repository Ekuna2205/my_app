class WashRecord {
  int? id;
  String carPlate;
  String washType;
  double price;
  String worker;
  DateTime date;

  WashRecord({
    this.id,
    required this.carPlate,
    required this.washType,
    required this.price,
    required this.worker,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plateNumber': carPlate,
      'washType': washType,
      'price': price,
      'worker': worker,
      'date': date.toIso8601String(),
    };
  }

  factory WashRecord.fromMap(Map<String, dynamic> map) {
    return WashRecord(
      id: map['id'],
      carPlate: map['plateNumber'],
      washType: map['washType'],
      price: map['price'],
      worker: map['worker'],
      date: DateTime.parse(map['date']),
    );
  }
}
