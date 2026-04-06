class Car {
  final int? id;
  final String plateNumber;
  final String model;
  final int price;

  const Car({
    this.id,
    required this.plateNumber,
    required this.model,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plateNumber': plateNumber,
      'model': model,
      'price': price,
    };
  }

  factory Car.fromMap(Map<String, dynamic> map) {
    return Car(
      id: map['id'] as int?,
      plateNumber: (map['plateNumber'] ?? '') as String,
      model: (map['model'] ?? '') as String,
      price: (map['price'] ?? 0) as int,
    );
  }
}
