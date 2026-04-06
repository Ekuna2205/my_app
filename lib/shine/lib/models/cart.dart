// lib/models/car.dart
class Car {
  int? id;
  String plateNumber;
  String carType;
  String washType;
  String worker;
  DateTime startTime;
  DateTime endTime;
  double price;

  Car({
    this.id,
    required this.plateNumber,
    required this.carType,
    required this.washType,
    required this.worker,
    required this.startTime,
    required this.endTime,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plateNumber': plateNumber,
      'carType': carType,
      'washType': washType,
      'worker': worker,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'price': price,
    };
  }

  factory Car.fromMap(Map<String, dynamic> map) {
    return Car(
      id: map['id'],
      plateNumber: map['plateNumber'],
      carType: map['carType'],
      washType: map['washType'],
      worker: map['worker'],
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      price: map['price'],
    );
  }
}
